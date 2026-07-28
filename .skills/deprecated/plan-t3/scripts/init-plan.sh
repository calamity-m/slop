#!/usr/bin/env bash
# init-plan.sh — create a plan-t3 bundle: overview, plan, deliverables, issues.
#
# Usage: init-plan.sh <slug> [--title "Human Title"]
#
# Bundle lands in <git-root>/.agents/plans/t3/<slug>/, gitignored so it's
# never accidentally committed. The root is fixed on purpose: plans must
# outlive the session, so no env override is offered — agents have used one
# to dump plans into /tmp. <git-root> falls back to the cwd when not in a
# git repo. Existing bundle files are never overwritten; re-running against
# an existing bundle prints its paths and exits 0 so the skill can resume
# safely.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-plan.sh <slug> [--title "Human Title"]

Creates a plan-t3 bundle directory with four files seeded from templates:
  overview.md      high-level solution overview (for a team lead to vet)
  plan.md          in-depth plan (for a fresh implementation agent)
  deliverables.md  progress tracker (updated during implementation)
  issues.md        risk/issue register (appended by reviews and implementors)

The bundle lands at <git-root>/.agents/plans/t3/<slug>/.
EOF
}

slug=""
title=""
while [ $# -gt 0 ]; do
  case "$1" in
    --title) title="${2:?--title needs a value}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -n "$slug" ]; then echo "unexpected argument: $1" >&2; usage >&2; exit 2; fi
      slug="$1"; shift ;;
  esac
done

if [ -z "$slug" ]; then usage >&2; exit 2; fi
case "$slug" in
  *[!a-z0-9-]*) echo "slug must be kebab-case ([a-z0-9-]): $slug" >&2; exit 2 ;;
esac

if [ -z "$title" ]; then
  title="$slug"
fi

plan_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
repo="$(basename "$plan_root")"
bundle="$plan_root/.agents/plans/t3/$slug"
templates_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
today="$(date +%Y-%m-%d)"

mkdir -p "$bundle"

created=0
for f in overview plan deliverables issues; do
  dest="$bundle/$f.md"
  if [ -e "$dest" ]; then
    continue
  fi
  sed -e "s|{{TITLE}}|$title|g" \
      -e "s|{{SLUG}}|$slug|g" \
      -e "s|{{REPO}}|$repo|g" \
      -e "s|{{DATE}}|$today|g" \
      -e "s|{{BUNDLE}}|$bundle|g" \
      "$templates_dir/$f.md" > "$dest"
  created=$((created + 1))
done

if [ "$created" -eq 0 ]; then
  echo "bundle already exists (no files written): $bundle"
else
  echo "bundle ready ($created file(s) created): $bundle"
fi
echo "  overview:     $bundle/overview.md"
echo "  plan:         $bundle/plan.md"
echo "  deliverables: $bundle/deliverables.md"
echo "  issues:       $bundle/issues.md"
