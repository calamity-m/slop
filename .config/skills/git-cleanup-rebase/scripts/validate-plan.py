#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from git_cleanup_plan import PlanError, short_rev, validate_plan_file


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate a git cleanup rebase plan.")
    parser.add_argument("--plan", required=True, help="Path to the cleanup plan JSON file.")
    parser.add_argument(
        "--allow-published",
        action="store_true",
        help="Allow validation to pass for a branch that already has an upstream.",
    )
    args = parser.parse_args()

    try:
        repo_root, plan, warnings, preflight = validate_plan_file(
            Path(args.plan),
            allow_published=args.allow_published,
        )
    except PlanError as exc:
        print("Plan validation failed:", file=sys.stderr)
        for line in str(exc).splitlines():
            print(f"- {line}", file=sys.stderr)
        return 1

    print("Plan is valid.")
    print(f"Branch: {preflight.branch}")
    if preflight.upstream:
        print(f"Upstream: {preflight.upstream}")
    print(f"Base: {short_rev(repo_root, plan.base)}")
    print(f"Commits in range: {sum(len(chunk.commits) for chunk in plan.chunks)}")
    print(f"Final chunks: {len(plan.chunks)}")
    for warning in warnings:
        print(f"Warning: {warning}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
