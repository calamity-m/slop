#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


class PlanError(Exception):
    pass


@dataclass
class Chunk:
    subject: str
    body: str
    commits: list[str]


@dataclass
class Plan:
    base: str
    chunks: list[Chunk]


@dataclass
class PreflightResult:
    branch: str
    upstream: str | None
    stash_count: int


def run_git(
    repo_root: Path,
    args: list[str],
    *,
    check: bool = True,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            ["git", *args],
            cwd=repo_root,
            env=env,
            capture_output=True,
            text=True,
            check=check,
        )
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip()
        stdout = exc.stdout.strip()
        detail = stderr or stdout or "git command failed"
        raise PlanError(f"git {' '.join(args)}: {detail}") from exc


def git_output(repo_root: Path, args: list[str]) -> str:
    return run_git(repo_root, args).stdout.strip()


def repo_root() -> Path:
    probe = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=False,
    )
    if probe.returncode != 0:
        raise PlanError("current directory is not inside a git repository")
    return Path(probe.stdout.strip())


def absolute_git_dir(repo_root: Path) -> Path:
    return Path(git_output(repo_root, ["rev-parse", "--absolute-git-dir"]))


def current_branch(repo_root: Path) -> str:
    branch = git_output(repo_root, ["rev-parse", "--abbrev-ref", "HEAD"])
    if branch == "HEAD":
        raise PlanError("detached HEAD is not supported")
    return branch


def current_upstream(repo_root: Path) -> str | None:
    probe = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if probe.returncode != 0:
        return None
    return probe.stdout.strip()


def ahead_behind(repo_root: Path, upstream: str) -> tuple[int, int]:
    counts = git_output(repo_root, ["rev-list", "--left-right", "--count", f"HEAD...{upstream}"])
    ahead_text, behind_text = counts.split()
    return int(ahead_text), int(behind_text)


def stash_count(repo_root: Path) -> int:
    output = git_output(repo_root, ["stash", "list"])
    if not output:
        return 0
    return len(output.splitlines())


def worktree_status(repo_root: Path) -> list[str]:
    output = git_output(repo_root, ["status", "--porcelain=v1", "--untracked-files=all"])
    if not output:
        return []
    return output.splitlines()


def in_progress_operations(git_dir: Path) -> list[str]:
    checks = {
        "rebase": [git_dir / "rebase-apply", git_dir / "rebase-merge"],
        "merge": [git_dir / "MERGE_HEAD"],
        "cherry-pick": [git_dir / "CHERRY_PICK_HEAD"],
        "revert": [git_dir / "REVERT_HEAD"],
        "bisect": [git_dir / "BISECT_LOG"],
    }
    active = []
    for name, paths in checks.items():
        if any(path.exists() for path in paths):
            active.append(name)
    return active


def resolve_commit(repo_root: Path, rev: str) -> str:
    return git_output(repo_root, ["rev-parse", "--verify", f"{rev}^{{commit}}"])


def is_ancestor(repo_root: Path, older: str, newer: str) -> bool:
    probe = subprocess.run(
        ["git", "merge-base", "--is-ancestor", older, newer],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    return probe.returncode == 0


def list_range_commits(repo_root: Path, base: str, head: str = "HEAD") -> list[str]:
    output = git_output(repo_root, ["rev-list", "--reverse", f"{base}..{head}"])
    if not output:
        return []
    return output.splitlines()


def list_merge_commits(repo_root: Path, base: str, head: str = "HEAD") -> list[str]:
    output = git_output(
        repo_root,
        ["rev-list", "--reverse", "--min-parents=2", f"{base}..{head}"],
    )
    if not output:
        return []
    return output.splitlines()


def short_rev(repo_root: Path, rev: str) -> str:
    return git_output(repo_root, ["rev-parse", "--short", rev])


def short_list(repo_root: Path, revs: list[str]) -> str:
    if not revs:
        return "(none)"
    return " ".join(short_rev(repo_root, rev) for rev in revs)


def sanitize_branch_fragment(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]+", "-", name.strip("/"))
    cleaned = re.sub(r"-{2,}", "-", cleaned).strip("-.")
    return cleaned or "branch"


def default_backup_branch(branch: str) -> str:
    stamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    return f"backup/{sanitize_branch_fragment(branch)}-pre-cleanup-{stamp}"


def validate_backup_branch_name(repo_root: Path, branch: str) -> None:
    run_git(repo_root, ["check-ref-format", "--branch", branch])
    exists = subprocess.run(
        ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{branch}"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if exists.returncode == 0:
        raise PlanError(f"backup branch already exists: {branch}")


def create_backup_branch(repo_root: Path, branch: str) -> None:
    run_git(repo_root, ["branch", branch])


def plan_message(chunk: Chunk) -> str:
    subject = chunk.subject.strip()
    body = chunk.body.strip()
    if body:
        return f"{subject}\n\n{body}\n"
    return f"{subject}\n"


def load_plan(path: Path) -> Plan:
    try:
        raw = json.loads(path.read_text())
    except FileNotFoundError as exc:
        raise PlanError(f"plan file not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise PlanError(f"plan file is not valid JSON: {exc}") from exc

    if not isinstance(raw, dict):
        raise PlanError("plan file must contain a JSON object")

    extra_keys = sorted(set(raw.keys()) - {"base", "chunks"})
    if extra_keys:
        raise PlanError(f"unexpected top-level keys: {', '.join(extra_keys)}")

    base = raw.get("base")
    if not isinstance(base, str) or not base.strip():
        raise PlanError("plan.base must be a non-empty string")

    raw_chunks = raw.get("chunks")
    if not isinstance(raw_chunks, list) or not raw_chunks:
        raise PlanError("plan.chunks must be a non-empty array")

    chunks: list[Chunk] = []
    for index, raw_chunk in enumerate(raw_chunks, start=1):
        if not isinstance(raw_chunk, dict):
            raise PlanError(f"chunk {index} must be an object")

        extra_chunk_keys = sorted(set(raw_chunk.keys()) - {"subject", "body", "commits"})
        if extra_chunk_keys:
            raise PlanError(
                f"chunk {index} has unexpected keys: {', '.join(extra_chunk_keys)}"
            )

        subject = raw_chunk.get("subject")
        if not isinstance(subject, str) or not subject.strip():
            raise PlanError(f"chunk {index} subject must be a non-empty string")
        if "\n" in subject:
            raise PlanError(f"chunk {index} subject must stay on one line")

        body = raw_chunk.get("body", "")
        if not isinstance(body, str):
            raise PlanError(f"chunk {index} body must be a string when present")

        commits = raw_chunk.get("commits")
        if not isinstance(commits, list) or not commits:
            raise PlanError(f"chunk {index} commits must be a non-empty array")
        if not all(isinstance(commit, str) and commit.strip() for commit in commits):
            raise PlanError(f"chunk {index} commits must contain only non-empty strings")

        chunks.append(
            Chunk(
                subject=subject.strip(),
                body=body.strip(),
                commits=[commit.strip() for commit in commits],
            )
        )

    return Plan(base=base.strip(), chunks=chunks)


def normalize_plan(repo_root: Path, plan: Plan) -> Plan:
    normalized_chunks = []
    for chunk in plan.chunks:
        normalized_commits = [resolve_commit(repo_root, commit) for commit in chunk.commits]
        normalized_chunks.append(
            Chunk(subject=chunk.subject, body=chunk.body, commits=normalized_commits)
        )
    return Plan(base=resolve_commit(repo_root, plan.base), chunks=normalized_chunks)


def validate_plan_against_repo(repo_root: Path, plan: Plan) -> list[str]:
    errors = []

    if not is_ancestor(repo_root, plan.base, "HEAD"):
        errors.append("plan.base must be an ancestor of HEAD")
        return errors

    actual_commits = list_range_commits(repo_root, plan.base)
    if not actual_commits:
        errors.append("no commits found between plan.base and HEAD")
        return errors

    merge_commits = list_merge_commits(repo_root, plan.base)
    if merge_commits:
        errors.append(
            "merge commits in the feature range are not supported: "
            + short_list(repo_root, merge_commits)
        )

    planned_commits = [commit for chunk in plan.chunks for commit in chunk.commits]
    if len(set(planned_commits)) != len(planned_commits):
        errors.append("plan commits must be unique; a commit appears more than once")

    unexpected = [commit for commit in planned_commits if commit not in set(actual_commits)]
    if unexpected:
        errors.append(
            "plan includes commits outside base..HEAD: " + short_list(repo_root, unexpected)
        )

    if planned_commits != actual_commits:
        errors.append(
            "plan commits must match the exact current order of base..HEAD.\n"
            f"expected: {short_list(repo_root, actual_commits)}\n"
            f"planned:  {short_list(repo_root, planned_commits)}"
        )

    return errors


def preflight_checks(repo_root: Path, *, allow_published: bool) -> tuple[list[str], list[str], PreflightResult]:
    errors = []
    warnings = []

    branch = current_branch(repo_root)
    git_dir = absolute_git_dir(repo_root)

    active = in_progress_operations(git_dir)
    if active:
        errors.append("git operation already in progress: " + ", ".join(active))

    status_lines = worktree_status(repo_root)
    if status_lines:
        errors.append("worktree must be clean before rewriting history")

    upstream = current_upstream(repo_root)
    if upstream:
        ahead, behind = ahead_behind(repo_root, upstream)
        if behind:
            errors.append(
                f"current branch diverges from upstream {upstream}; sync it before cleanup"
            )
        elif not allow_published:
            errors.append(
                f"current branch already has upstream {upstream}; rerun with --allow-published after user confirmation"
            )
        else:
            warnings.append(
                f"rewriting branch with existing upstream {upstream}; a later force push will be required"
            )

    stashes = stash_count(repo_root)
    if stashes:
        warnings.append(f"stash entries present ({stashes}); they will not be modified")

    return errors, warnings, PreflightResult(branch=branch, upstream=upstream, stash_count=stashes)


def validate_plan_file(
    plan_path: Path,
    *,
    allow_published: bool,
) -> tuple[Path, Plan, list[str], PreflightResult]:
    repo = repo_root()
    plan = normalize_plan(repo, load_plan(plan_path))
    errors, warnings, preflight = preflight_checks(repo, allow_published=allow_published)
    errors.extend(validate_plan_against_repo(repo, plan))
    if errors:
        raise PlanError("\n".join(errors))
    return repo, plan, warnings, preflight
