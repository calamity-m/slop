#!/usr/bin/env bash
# log-issue.sh — prepend a dated, signed entry to the Log section of a
# plan-t3 bundle's issues.md.
#
# Usage: log-issue.sh <bundle-dir|issues.md> <author> <source> <message...>
#   e.g. log-issue.sh .agents/plans/t3/oauth-refresh agent:claude self \
#          "Deliverable 2 blocked: token endpoint undocumented."
#
# The source names what raised the issue (self, grugbrain, peer-review, user,
# etc.). New entries go newest-at-top, directly under the "## Log" heading
# (after any template comment), so the format and ordering never drift between
# planning reviews and implementation sessions.
set -euo pipefail

if [ $# -lt 4 ]; then
  echo "usage: log-issue.sh <bundle-dir|issues.md> <author> <source> <message...>" >&2
  exit 2
fi

target="$1"; author="$2"; source="$3"; shift 3
message="$*"

if [ -d "$target" ]; then
  file="$target/issues.md"
else
  file="$target"
fi
if [ ! -f "$file" ]; then
  echo "issues file not found: $file" >&2
  exit 1
fi
if ! grep -q '^## Log$' "$file"; then
  echo "no '## Log' section in $file — add the entry manually" >&2
  exit 1
fi

entry="- **$(date +%Y-%m-%d) — $author - source:$source** - $message"

tmp="$(mktemp "$(dirname "$file")/.log-issue.XXXXXX")"
# Insert after "## Log" plus any trailing blank lines / HTML comment block,
# i.e. immediately before the first existing entry (or at EOF if none).
awk -v entry="$entry" '
  pending {
    if ($0 ~ /^<!--/) incomment = 1
    if (incomment || $0 ~ /^[[:space:]]*$/) {
      if ($0 ~ /-->[[:space:]]*$/) incomment = 0
      print; next
    }
    print entry
    pending = 0
  }
  { print }
  $0 == "## Log" { pending = 1 }
  END { if (pending) print entry }
' "$file" > "$tmp"
mv "$tmp" "$file"

echo "logged to $file:"
echo "  $entry"
