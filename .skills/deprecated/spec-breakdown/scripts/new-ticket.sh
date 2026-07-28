#!/usr/bin/env bash
# new-ticket.sh — create one ticket file inside a spec breakdown directory.
#
# Usage: new-ticket.sh <spec-slug> <number> <ticket-slug> [--title "Human Title"]
#
# Ticket lands at <git-root>/docs/specs/<spec-slug>/T<number>-<ticket-slug>.md.
# The file's H1 is the issue title and everything below it is the issue body
# when published to a tracker, so one file maps to one issue. Never
# overwrites; re-running against an existing ticket prints its path and exits
# 0. The index (tickets.md) is not touched — add the ticket's entry there
# yourself.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: new-ticket.sh <spec-slug> <number> <ticket-slug> [--title "Human Title"]

Creates a single ticket file seeded from the template at
<git-root>/docs/specs/<spec-slug>/T<number>-<ticket-slug>.md.
EOF
}

spec_slug=""
number=""
ticket_slug=""
title=""
while [ $# -gt 0 ]; do
  case "$1" in
    --title) title="${2:?--title needs a value}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "$spec_slug" ]; then spec_slug="$1"
      elif [ -z "$number" ]; then number="$1"
      elif [ -z "$ticket_slug" ]; then ticket_slug="$1"
      else echo "unexpected argument: $1" >&2; usage >&2; exit 2; fi
      shift ;;
  esac
done

if [ -z "$spec_slug" ] || [ -z "$number" ] || [ -z "$ticket_slug" ]; then usage >&2; exit 2; fi
case "$spec_slug" in
  *[!a-z0-9-]*) echo "spec-slug must be kebab-case ([a-z0-9-]): $spec_slug" >&2; exit 2 ;;
esac
case "$number" in
  ''|*[!0-9]*) echo "number must be a positive integer: $number" >&2; exit 2 ;;
esac
case "$ticket_slug" in
  *[!a-z0-9-]*) echo "ticket-slug must be kebab-case ([a-z0-9-]): $ticket_slug" >&2; exit 2 ;;
esac

if [ -z "$title" ]; then
  title="$ticket_slug"
fi

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
dir="$root/docs/specs/$spec_slug"
ticket="$dir/T$number-$ticket_slug.md"
template="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)/ticket.md"

if [ ! -e "$dir/tickets.md" ]; then
  echo "no tickets index at docs/specs/$spec_slug/tickets.md — run init-breakdown.sh first" >&2
  exit 2
fi

if [ -e "$ticket" ]; then
  echo "ticket already exists (not overwritten): $ticket"
  exit 0
fi

sed -e "s|{{TITLE}}|$title|g" \
    -e "s|{{SPEC_SLUG}}|$spec_slug|g" \
    "$template" > "$ticket"

echo "ticket ready: $ticket"
