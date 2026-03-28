#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path


EXECPLAN_HEADINGS = [
    "## Purpose / Big Picture",
    "## Progress",
    "## Surprises & Discoveries",
    "## Decision Log",
    "## Outcomes & Retrospective",
    "## Context and Orientation",
    "## Plan of Work",
    "## Concrete Steps",
    "## Validation and Acceptance",
    "## Idempotence and Recovery",
    "## Artifacts and Notes",
    "## Interfaces and Dependencies",
]

LIVING_MARKERS = [
    "Review status:",
    "This ExecPlan is a living document.",
    "`Progress`",
    "`Surprises & Discoveries`",
    "`Decision Log`",
    "`Outcomes & Retrospective`",
]


def require_file(path: Path, label: str, errors: list[str]) -> str:
    if not path.exists():
        errors.append(f"missing {label}: {path}")
        return ""
    return path.read_text(encoding="utf-8")


def require_substrings(content: str, label: str, path: Path, required: list[str], errors: list[str]) -> None:
    for item in required:
        if item not in content:
            errors.append(f"{label} {path} is missing required text: {item}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate a concrete ExecPlan against the shared PLANS path.")
    parser.add_argument("--repo-root", required=True, help="Repository root to inspect.")
    parser.add_argument("--plans-path", default="PLANS.md", help="Repository-relative path to the shared PLANS.md file.")
    parser.add_argument("--execplan", required=True, help="Repository-relative path to the ExecPlan file.")
    parser.add_argument("--agents-path", default="AGENTS.md", help="Optional AGENTS.md path for existence checks.")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    execplan_file = repo_root / args.execplan
    plans_file = repo_root / args.plans_path
    agents_file = repo_root / args.agents_path
    errors: list[str] = []

    execplan = require_file(execplan_file, "ExecPlan", errors)
    require_file(plans_file, "PLANS.md", errors)
    if not agents_file.exists():
        print(f"warning: AGENTS.md not found at {agents_file}", file=sys.stderr)

    if execplan:
        require_substrings(execplan, "ExecPlan", execplan_file, EXECPLAN_HEADINGS, errors)
        require_substrings(execplan, "ExecPlan", execplan_file, LIVING_MARKERS, errors)
        if args.plans_path not in execplan:
            errors.append(f"ExecPlan {execplan_file} does not reference {args.plans_path}")

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1

    print("ok: ExecPlan structure looks valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
