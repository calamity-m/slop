#!/usr/bin/env bash
# init-breakdown.sh — create the tickets index for a spec breakdown.
#
# Usage: init-breakdown.sh <spec-slug> [--title "Human Title"]
#
# Index lands at <git-root>/docs/specs/<spec-slug>/tickets.md, beside the
# spec it derives from (docs/specs/<spec-slug>.md). Committed like the spec —
# the markdown breakdown is the source of truth even after publishing to a
# tracker. <git-root> falls back to the cwd when not in a git repo. Never
# overwrites; re-running against an existing index prints its path and exits
# 0 so the skill can resume safely.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-breakdown.sh <spec-slug> [--title "Human Title"]

Creates the breakdown directory and tickets index (sequencing + ticket
checklist) seeded from the template at
<git-root>/docs/specs/<spec-slug>/tickets.md.
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
  *[!a-z0-9-]*) echo "spec-slug must be kebab-case ([a-z0-9-]): $slug" >&2; exit 2 ;;
esac

if [ -z "$title" ]; then
  title="$slug"
fi

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
index="$root/docs/specs/$slug/tickets.md"
template="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)/tickets.md"
today="$(date +%Y-%m-%d)"

if [ ! -e "$root/docs/specs/$slug.md" ]; then
  echo "warning: no spec found at docs/specs/$slug.md — index still created" >&2
fi

if [ -e "$index" ]; then
  echo "tickets index already exists (not overwritten): $index"
  exit 0
fi

mkdir -p "$(dirname "$index")"
sed -e "s|{{TITLE}}|$title|g" \
    -e "s|{{SPEC_SLUG}}|$slug|g" \
    -e "s|{{DATE}}|$today|g" \
    "$template" > "$index"

echo "tickets index ready: $index"
