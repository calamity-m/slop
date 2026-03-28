#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path


PLANS_HEADINGS = [
    "## How to use ExecPlans and PLANS.md",
    "## Requirements",
    "## Formatting",
    "## Guidelines",
    "## Milestones",
    "## Living Plans And Design Decisions",
    "## Skeleton Of A Good ExecPlan",
]

EXECPLAN_HEADINGS = [
    "## Purpose / Big Picture",
    "## Requirements",
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
    parser = argparse.ArgumentParser(description="Validate AGENTS.md, PLANS.md, and optional ExecPlan files.")
    parser.add_argument("--repo-root", required=True, help="Repository root to inspect.")
    parser.add_argument("--plan-path", default="PLANS.md", help="Repository-relative path to the shared PLANS.md file.")
    parser.add_argument("--agents-path", default="AGENTS.md", help="Repository-relative path to AGENTS.md.")
    parser.add_argument("--execplan", help="Optional repository-relative path to a concrete ExecPlan file.")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    plan_file = repo_root / args.plan_path
    agents_file = repo_root / args.agents_path
    errors: list[str] = []

    agents = require_file(agents_file, "AGENTS.md", errors)
    plans = require_file(plan_file, "PLANS.md", errors)

    if agents:
        require_substrings(agents, "AGENTS.md", agents_file, ["ExecPlan", args.plan_path], errors)
    if plans:
        require_substrings(plans, "PLANS.md", plan_file, PLANS_HEADINGS, errors)

    if args.execplan:
        execplan_file = repo_root / args.execplan
        execplan = require_file(execplan_file, "ExecPlan", errors)
        if execplan:
            require_substrings(execplan, "ExecPlan", execplan_file, EXECPLAN_HEADINGS, errors)
            if args.plan_path not in execplan:
                errors.append(f"ExecPlan {execplan_file} does not reference {args.plan_path}")

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1

    print("ok: ExecPlan setup looks consistent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
