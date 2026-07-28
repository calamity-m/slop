#!/usr/bin/env bash
# init-spec.sh — create a spec document from the template.
#
# Usage: init-spec.sh <slug> [--title "Human Title"]
#
# Spec lands at <git-root>/docs/specs/<slug>/spec.md. Specs are durable
# review artifacts meant to be committed, unlike plans — hence docs/, not a
# gitignored area. The per-slug directory leaves room for sibling files
# (diagrams, ADRs) alongside spec.md. <git-root> falls back to the cwd when
# not in a git repo. Never overwrites; re-running against an existing spec
# prints its path and exits 0 so the skill can resume safely.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-spec.sh <slug> [--title "Human Title"]

Creates an engineering spec (problem, goals, requirements, design, edge
cases, acceptance criteria) seeded from the template at
<git-root>/docs/specs/<slug>/spec.md.
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

spec_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
repo="$(basename "$spec_root")"
spec="$spec_root/docs/specs/$slug/spec.md"
template="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)/spec.md"
today="$(date +%Y-%m-%d)"

if [ -e "$spec" ]; then
  echo "spec already exists (not overwritten): $spec"
  exit 0
fi

mkdir -p "$(dirname "$spec")"
sed -e "s|{{TITLE}}|$title|g" \
    -e "s|{{SLUG}}|$slug|g" \
    -e "s|{{REPO}}|$repo|g" \
    -e "s|{{DATE}}|$today|g" \
    "$template" > "$spec"

echo "spec ready: $spec"
