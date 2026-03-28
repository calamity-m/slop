#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


def render_template(plans_path: str, title: str) -> str:
    template_path = Path(__file__).resolve().parent.parent / "assets" / "EXECPLAN.template.md"
    return template_path.read_text(encoding="utf-8").replace("__PLANS_PATH__", plans_path).replace(
        "<Short, action-oriented description>", title
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Create a starter ExecPlan file from the bundled template.")
    parser.add_argument("--repo-root", required=True, help="Repository root that will contain the plan.")
    parser.add_argument("--plans-path", default="PLANS.md", help="Repository-relative path to the shared PLANS.md file.")
    parser.add_argument("--output", required=True, help="Repository-relative path for the new ExecPlan file.")
    parser.add_argument("--title", required=True, help="Plan title to place in the H1.")
    parser.add_argument("--force", action="store_true", help="Overwrite the output file if it exists.")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    output = repo_root / args.output
    if output.exists() and not args.force:
        raise SystemExit(f"error: output already exists: {output}")

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_template(args.plans_path, args.title), encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
