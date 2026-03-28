#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path


AGENTS_SNIPPET = """## ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in {plan_path}) from design to implementation.

Treat each ExecPlan as a living, self-contained document. Keep progress, discoveries, decisions, and outcomes current as work proceeds.
"""


def load_asset(name: str) -> str:
    return (Path(__file__).resolve().parent.parent / "assets" / name).read_text(encoding="utf-8")


def write_if_missing(path: Path, content: str, force: bool) -> str:
    if path.exists() and not force:
        return f"kept existing {path}"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return f"wrote {path}"


def ensure_agents(agents_path: Path, plan_path: str, force: bool) -> str:
    snippet = AGENTS_SNIPPET.format(plan_path=plan_path).rstrip() + "\n"
    if not agents_path.exists():
        agents_path.write_text(snippet, encoding="utf-8")
        return f"created {agents_path}"

    current = agents_path.read_text(encoding="utf-8")
    if "## ExecPlans" in current or "# ExecPlans" in current:
        if plan_path in current:
            return f"kept existing {agents_path} (already references ExecPlans)"
        if force:
            updated = current.rstrip() + "\n\n" + snippet
            agents_path.write_text(updated, encoding="utf-8")
            return f"appended ExecPlans section to {agents_path}"
        return f"kept existing {agents_path} (ExecPlans section already present; review manually if the path should change)"

    updated = current.rstrip() + "\n\n" + snippet
    agents_path.write_text(updated, encoding="utf-8")
    return f"appended ExecPlans section to {agents_path}"


def render_template(name: str, plan_path: str) -> str:
    return load_asset(name).replace("__PLANS_PATH__", plan_path)


def main() -> int:
    parser = argparse.ArgumentParser(description="Initialize AGENTS.md + PLANS.md ExecPlan support in a repository.")
    parser.add_argument("--repo-root", required=True, help="Repository root to modify.")
    parser.add_argument("--plan-path", default="PLANS.md", help="Repository-relative path to the shared PLANS.md file.")
    parser.add_argument("--agents-path", default="AGENTS.md", help="Repository-relative path to AGENTS.md.")
    parser.add_argument("--example-plan", help="Optional repository-relative path for a starter ExecPlan file.")
    parser.add_argument("--force", action="store_true", help="Overwrite template-managed files if they already exist.")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).expanduser().resolve()
    plan_file = repo_root / args.plan_path
    agents_file = repo_root / args.agents_path

    messages: list[str] = []
    plan_content = render_template("PLANS.md.template", args.plan_path)
    messages.append(write_if_missing(plan_file, plan_content, args.force))

    agents_file.parent.mkdir(parents=True, exist_ok=True)
    messages.append(ensure_agents(agents_file, args.plan_path, args.force))

    if args.example_plan:
        example_file = repo_root / args.example_plan
        example_content = render_template("EXECPLAN.template.md", args.plan_path)
        messages.append(write_if_missing(example_file, example_content, args.force))

    for message in messages:
        print(message)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
