#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from git_cleanup_plan import (
    PlanError,
    create_backup_branch,
    default_backup_branch,
    plan_message,
    run_git,
    short_rev,
    validate_backup_branch_name,
    validate_plan_file,
)


def write_wrapper(path: Path, content: str) -> None:
    path.write_text(content)
    path.chmod(0o755)


def write_state(state_dir: Path, messages: list[str], todo_lines: list[str]) -> None:
    (state_dir / "messages.json").write_text(json.dumps(messages))
    (state_dir / "message-index.txt").write_text("0\n")
    (state_dir / "todo.txt").write_text("".join(f"{line}\n" for line in todo_lines))


def sequence_editor(state_dir: Path, target_file: Path) -> int:
    target_file.write_text((state_dir / "todo.txt").read_text())
    return 0


def commit_editor(state_dir: Path, target_file: Path) -> int:
    messages = json.loads((state_dir / "messages.json").read_text())
    index_path = state_dir / "message-index.txt"
    next_index = int(index_path.read_text().strip())
    if next_index >= len(messages):
        raise PlanError("editor queue exhausted before rebase finished")
    target_file.write_text(messages[next_index])
    index_path.write_text(f"{next_index + 1}\n")
    return 0


def create_wrappers(state_dir: Path) -> tuple[Path, Path]:
    runner = Path(__file__).resolve()
    python = Path(sys.executable).resolve()

    sequence_path = state_dir / "sequence-editor.sh"
    write_wrapper(
        sequence_path,
        (
            "#!/usr/bin/env bash\n"
            "exec "
            f"{shlex.quote(str(python))} "
            f"{shlex.quote(str(runner))} "
            "_sequence-editor "
            f"{shlex.quote(str(state_dir))} "
            "\"$1\"\n"
        ),
    )

    editor_path = state_dir / "commit-editor.sh"
    write_wrapper(
        editor_path,
        (
            "#!/usr/bin/env bash\n"
            "exec "
            f"{shlex.quote(str(python))} "
            f"{shlex.quote(str(runner))} "
            "_commit-editor "
            f"{shlex.quote(str(state_dir))} "
            "\"$1\"\n"
        ),
    )

    return sequence_path, editor_path


def execute_rebase(plan_path: Path, allow_published: bool, backup_branch: str | None, keep_state: bool) -> int:
    repo_root, plan, warnings, preflight = validate_plan_file(
        plan_path,
        allow_published=allow_published,
    )

    chosen_backup = backup_branch or default_backup_branch(preflight.branch)
    validate_backup_branch_name(repo_root, chosen_backup)
    create_backup_branch(repo_root, chosen_backup)

    messages = [plan_message(chunk) for chunk in plan.chunks]
    todo_lines = []
    for chunk in plan.chunks:
        todo_lines.append(f"reword {chunk.commits[0]}")
        todo_lines.extend(f"fixup {commit}" for commit in chunk.commits[1:])

    temp_root = Path(tempfile.mkdtemp(prefix="git-cleanup-rebase-"))
    write_state(temp_root, messages, todo_lines)
    sequence_editor_path, editor_path = create_wrappers(temp_root)

    env = dict(os.environ)
    env["GIT_SEQUENCE_EDITOR"] = str(sequence_editor_path)
    env["GIT_EDITOR"] = str(editor_path)

    try:
        run_git(repo_root, ["rebase", "-i", plan.base], env=env)
    except PlanError as exc:
        print("Rebase failed.", file=sys.stderr)
        print(f"Backup branch: {chosen_backup}", file=sys.stderr)
        for warning in warnings:
            print(f"Warning: {warning}", file=sys.stderr)
        print(str(exc), file=sys.stderr)
        print("If git reports an in-progress rebase, use `git rebase --abort` to return to the pre-run state.", file=sys.stderr)
        if keep_state:
            print(f"State dir: {temp_root}", file=sys.stderr)
        else:
            shutil.rmtree(temp_root, ignore_errors=True)
        return 1

    if not keep_state:
        shutil.rmtree(temp_root, ignore_errors=True)

    print(f"Backup branch: {chosen_backup}")
    print(f"Base: {short_rev(repo_root, plan.base)}")
    print(f"Rewrote {sum(len(chunk.commits) for chunk in plan.chunks)} commits into {len(plan.chunks)} commit(s).")
    for warning in warnings:
        print(f"Warning: {warning}")
    return 0


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "_sequence-editor":
        try:
            return sequence_editor(Path(sys.argv[2]), Path(sys.argv[3]))
        except Exception as exc:  # noqa: BLE001
            print(str(exc), file=sys.stderr)
            return 1

    if len(sys.argv) > 1 and sys.argv[1] == "_commit-editor":
        try:
            return commit_editor(Path(sys.argv[2]), Path(sys.argv[3]))
        except Exception as exc:  # noqa: BLE001
            print(str(exc), file=sys.stderr)
            return 1

    parser = argparse.ArgumentParser(description="Run a git cleanup rebase plan.")
    parser.add_argument("--plan", required=True, help="Path to the cleanup plan JSON file.")
    parser.add_argument(
        "--allow-published",
        action="store_true",
        help="Allow rewriting a branch that already has an upstream.",
    )
    parser.add_argument(
        "--backup-branch",
        help="Name for the backup branch. Defaults to backup/<branch>-pre-cleanup-<timestamp>.",
    )
    parser.add_argument(
        "--keep-state",
        action="store_true",
        help="Keep the temporary rebase state directory after the run.",
    )
    args = parser.parse_args()

    try:
        return execute_rebase(
            Path(args.plan),
            allow_published=args.allow_published,
            backup_branch=args.backup_branch,
            keep_state=args.keep_state,
        )
    except PlanError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
