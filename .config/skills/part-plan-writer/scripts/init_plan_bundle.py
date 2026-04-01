#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import re
from pathlib import Path


def slugify(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9]+", "-", value)
    value = re.sub(r"-{2,}", "-", value).strip("-")
    return value or "plan"


def load_asset(name: str) -> str:
    return (Path(__file__).resolve().parent.parent / "assets" / name).read_text(encoding="utf-8")


def relative_link(from_path: Path, to_path: Path) -> str:
    return os.path.relpath(to_path, start=from_path.parent)


def write_file(path: Path, content: str, force: bool) -> str:
    if path.exists() and not force:
        raise FileExistsError(f"refusing to overwrite existing file without --force: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return str(path)


def ensure_context(path: Path, force: bool) -> tuple[str, bool]:
    if path.exists() and not force:
        return (str(path), False)
    content = load_asset("PLAN_CONTEXT.template.md")
    write_file(path, content, force=True if path.exists() else force)
    return (str(path), True)


def build_part_specs(part_count: int, part_names: list[str]) -> list[dict[str, str]]:
    specs: list[dict[str, str]] = []
    for index in range(1, part_count + 1):
        label = part_names[index - 1] if part_names else f"Part {index:02d}"
        suffix = slugify(label) if part_names else ""
        filename = f"part-{index:02d}.md" if not suffix else f"part-{index:02d}-{suffix}.md"
        specs.append(
            {
                "number": f"{index:02d}",
                "name": label,
                "filename": filename,
            }
        )
    return specs


def render_task_readme(template: str, title: str, readme_path: Path, context_path: Path, specs: list[dict[str, str]]) -> str:
    rows = []
    for spec in specs:
        rows.append(f"| {spec['number']} | [{spec['name']}]({spec['filename']}) | planned | _TBD_ |")
    return (
        template.replace("__TITLE__", title)
        .replace("__PART_COUNT__", str(len(specs)))
        .replace("__CONTEXT_LINK__", relative_link(readme_path, context_path))
        .replace("__PART_ROWS__", "\n".join(rows))
    )


def render_part(template: str, readme_path: Path, context_path: Path, spec: dict[str, str]) -> str:
    part_path = readme_path.parent / spec["filename"]
    return (
        template.replace("__PART_NUMBER__", spec["number"])
        .replace("__PART_NAME__", spec["name"])
        .replace("__MASTER_PLAN_LINK__", relative_link(part_path, readme_path))
        .replace("__CONTEXT_LINK__", relative_link(part_path, context_path))
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create a tracked multi-part plan bundle.")
    parser.add_argument("--repo-root", required=True, help="Repository root that will contain the plan bundle.")
    parser.add_argument("--title", required=True, help="Human-readable title for the task README.")
    parser.add_argument("--slug", help="Optional bundle slug. Defaults to a slugified title.")
    parser.add_argument("--parts", required=True, type=int, help="Number of part files to create.")
    parser.add_argument("--part-name", action="append", default=[], help="Optional part name. Pass once per part.")
    parser.add_argument("--plans-dir", default="plans", help="Repository-relative directory that stores task bundles.")
    parser.add_argument("--context-path", default="PLAN_CONTEXT.md", help="Repository-relative shared context file path.")
    parser.add_argument("--force", action="store_true", help="Overwrite generated files if they already exist.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.parts < 1:
        raise SystemExit("error: --parts must be at least 1")
    if args.part_name and len(args.part_name) != args.parts:
        raise SystemExit("error: pass either zero --part-name values or exactly one per part")

    repo_root = Path(args.repo_root).expanduser().resolve()
    slug = args.slug or slugify(args.title)
    bundle_dir = repo_root / args.plans_dir / slug
    readme_path = bundle_dir / "README.md"
    context_path = repo_root / args.context_path

    specs = build_part_specs(args.parts, args.part_name)
    task_template = load_asset("TASK_README.template.md")
    part_template = load_asset("PART.template.md")

    context_file, created_context = ensure_context(context_path, args.force)

    created_files: list[str] = []
    created_files.append(write_file(readme_path, render_task_readme(task_template, args.title, readme_path, context_path, specs), args.force))

    for spec in specs:
        part_path = bundle_dir / spec["filename"]
        created_files.append(write_file(part_path, render_part(part_template, readme_path, context_path, spec), args.force))

    if created_context:
        print(f"created context: {context_file}")
    else:
        print(f"kept context: {context_file}")

    for path in created_files:
        print(f"wrote: {path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
