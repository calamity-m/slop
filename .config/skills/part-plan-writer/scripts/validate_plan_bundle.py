#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


CONTEXT_HEADINGS = [
    "# Plan Context",
    "## Purpose",
    "## File Layout",
    "## Update Rules",
    "## Status Values",
    "## Working Agreement",
]

TASK_HEADINGS = [
    "Status:",
    "Review status:",
    "Part count:",
    "## Objective",
    "## Constraints",
    "## Part Tracker",
    "## Global Progress Log",
    "## Review Findings",
    "## Decision Log",
    "## Acceptance",
    "## Risks and Dependencies",
]

PART_HEADINGS = [
    "Status:",
    "## Outcome",
    "## Scope",
    "## Dependencies",
    "## Checklist",
    "## Progress Log",
    "## Discoveries",
    "## Validation",
    "## Next Handoff",
]

ALLOWED_STATUSES = {"planned", "in-progress", "blocked", "done"}
ALLOWED_REVIEW_STATUSES = {"draft", "in-review", "reviewed", "blocked-no-subagents"}


def read_text(path: Path, label: str, errors: list[str]) -> str:
    if not path.exists():
        errors.append(f"missing {label}: {path}")
        return ""
    return path.read_text(encoding="utf-8")


def require_strings(content: str, path: Path, required: list[str], errors: list[str]) -> None:
    for item in required:
        if item not in content:
            errors.append(f"{path} is missing required text: {item}")


def extract_status(content: str, path: Path, errors: list[str]) -> None:
    match = re.search(r"^Status:\s*([a-z-]+)\s*$", content, re.MULTILINE)
    if not match:
        errors.append(f"{path} is missing a valid Status line")
        return
    status = match.group(1)
    if status not in ALLOWED_STATUSES:
        errors.append(f"{path} has invalid status '{status}'")


def extract_review_status(content: str, path: Path, errors: list[str]) -> None:
    match = re.search(r"^Review status:\s*([a-z-]+)\s*$", content, re.MULTILINE)
    if not match:
        errors.append(f"{path} is missing a valid Review status line")
        return
    status = match.group(1)
    if status not in ALLOWED_REVIEW_STATUSES:
        errors.append(f"{path} has invalid review status '{status}'")


def extract_part_count(content: str, path: Path, errors: list[str]) -> int | None:
    match = re.search(r"^Part count:\s*(\d+)\s*$", content, re.MULTILINE)
    if not match:
        errors.append(f"{path} is missing a Part count line")
        return None
    return int(match.group(1))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate a tracked multi-part plan bundle.")
    parser.add_argument("--repo-root", required=True, help="Repository root to inspect.")
    parser.add_argument("--bundle", required=True, help="Repository-relative path to the task bundle directory.")
    parser.add_argument("--context-path", default="PLAN_CONTEXT.md", help="Repository-relative path to the shared context file.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).expanduser().resolve()
    bundle_dir = repo_root / args.bundle
    readme_path = bundle_dir / "README.md"
    context_path = repo_root / args.context_path
    errors: list[str] = []

    context = read_text(context_path, "PLAN_CONTEXT.md", errors)
    if context:
        require_strings(context, context_path, CONTEXT_HEADINGS, errors)

    readme = read_text(readme_path, "task README", errors)
    declared_part_count: int | None = None
    if readme:
        require_strings(readme, readme_path, TASK_HEADINGS, errors)
        extract_status(readme, readme_path, errors)
        extract_review_status(readme, readme_path, errors)
        declared_part_count = extract_part_count(readme, readme_path, errors)
        if args.context_path not in readme:
            errors.append(f"{readme_path} does not reference {args.context_path}")

    part_files = sorted(bundle_dir.glob("part-*.md"))
    if not part_files:
        errors.append(f"no part files found in {bundle_dir}")

    if declared_part_count is not None and declared_part_count != len(part_files):
        errors.append(
            f"{readme_path} declares {declared_part_count} parts but {len(part_files)} part files exist in {bundle_dir}"
        )

    for part_path in part_files:
        part = read_text(part_path, "part file", errors)
        if not part:
            continue
        require_strings(part, part_path, PART_HEADINGS, errors)
        extract_status(part, part_path, errors)
        if "README.md" not in part:
            errors.append(f"{part_path} does not reference README.md")
        if args.context_path not in part:
            errors.append(f"{part_path} does not reference {args.context_path}")

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1

    print("ok: plan bundle structure looks valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
