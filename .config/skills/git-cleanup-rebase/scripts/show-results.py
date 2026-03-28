#!/usr/bin/env python3

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from git_cleanup_plan import PlanError, current_branch, git_output, repo_root, resolve_commit, run_git


def log_lines(repo: Path, revision_range: str) -> list[str]:
    output = git_output(repo, ["log", "--reverse", "--oneline", revision_range])
    if not output:
        return []
    return output.splitlines()


def range_diff(repo: Path, before_range: str, after_range: str) -> str:
    proc = subprocess.run(
        ["git", "range-diff", before_range, after_range],
        cwd=repo,
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        stderr = proc.stderr.strip()
        return stderr or "(range-diff unavailable)"
    return proc.stdout.strip() or "(range-diff is empty)"


def tree_id(repo: Path, rev: str) -> str:
    return git_output(repo, ["rev-parse", f"{rev}^{{tree}}"])


def main() -> int:
    parser = argparse.ArgumentParser(description="Show before/after history for git cleanup rebase.")
    parser.add_argument("--base", required=True, help="Base revision for the feature range.")
    parser.add_argument("--backup-branch", required=True, help="Backup branch created before cleanup.")
    args = parser.parse_args()

    try:
        repo = repo_root()
        branch = current_branch(repo)
        base = resolve_commit(repo, args.base)
        backup = resolve_commit(repo, args.backup_branch)
    except PlanError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    before_range = f"{base}..{backup}"
    after_range = f"{base}..HEAD"
    before = log_lines(repo, before_range)
    after = log_lines(repo, after_range)
    same_tree = tree_id(repo, backup) == tree_id(repo, "HEAD")

    print(f"Branch: {branch}")
    print(f"Base: {args.base}")
    print(f"Backup branch: {args.backup_branch}")
    print(f"Tree unchanged: {'yes' if same_tree else 'no'}")
    print(f"Before commit count: {len(before)}")
    print(f"After commit count: {len(after)}")
    print()
    print("=== Before ===")
    print("\n".join(before) if before else "(none)")
    print()
    print("=== After ===")
    print("\n".join(after) if after else "(none)")
    print()
    print("=== Range Diff ===")
    print(range_diff(repo, before_range, after_range))
    print()
    print("=== Working Tree Diff ===")
    diff = run_git(repo, ["diff", "--stat", args.backup_branch, "HEAD"]).stdout.strip()
    print(diff or "(no content diff)")

    if same_tree:
        return 0
    print("cleanup rewrite changed the tree; inspect before pushing", file=sys.stderr)
    return 1
