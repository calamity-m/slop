#!/usr/bin/env bash
# init-plan.sh — create a plan-t1 single-file plan from the template.
#
# Usage: init-plan.sh <slug> [--title "Human Title"] [--repo <name>]
#
# Plan lands at $PLAN_T1_ROOT/<repo>/t1/<slug>.md (default root:
# ~/.agents/plans). <repo> defaults to the git-root basename, falling back
# to the cwd basename. Never overwrites; re-running against an existing
# plan prints its path and exits 0 so the skill can resume safely.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-plan.sh <slug> [--title "Human Title"] [--repo <name>]

Creates a single-file plan-t1 plan (context, approach, deliverables with
checklists, verification, log) seeded from the template.

Environment:
  PLAN_T1_ROOT     plan root (default: ~/.agents/plans)
EOF
}

slug=""
title=""
repo=""
while [ $# -gt 0 ]; do
  case "$1" in
    --title) title="${2:?--title needs a value}"; shift 2 ;;
    --repo)  repo="${2:?--repo needs a value}"; shift 2 ;;
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

if [ -z "$repo" ]; then
  repo="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
fi
if [ -z "$title" ]; then
  title="$slug"
fi

root="${PLAN_T1_ROOT:-$HOME/.agents/plans}"
plan="$root/$repo/t1/$slug.md"
template="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)/plan.md"
today="$(date +%Y-%m-%d)"

if [ -e "$plan" ]; then
  echo "plan already exists (not overwritten): $plan"
  exit 0
fi

mkdir -p "$(dirname "$plan")"
sed -e "s|{{TITLE}}|$title|g" \
    -e "s|{{SLUG}}|$slug|g" \
    -e "s|{{REPO}}|$repo|g" \
    -e "s|{{DATE}}|$today|g" \
    -e "s|{{FILE}}|$plan|g" \
    "$template" > "$plan"

echo "plan ready: $plan"
