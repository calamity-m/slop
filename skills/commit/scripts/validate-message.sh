#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  validate-message.sh "<subject>" ["<body>"]

Validate a commit message against:
  <type>(scope): short

The optional body should be short and plain.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 2
fi

subject="$1"
body="${2:-}"

if [[ ! "$subject" =~ ^[a-z][a-z0-9-]*\([a-z0-9][a-z0-9-]*\):\ .+$ ]]; then
  echo "error: subject must match <type>(scope): short" >&2
  exit 1
fi

if [[ ${#subject} -gt 72 ]]; then
  echo "error: subject is too long (${#subject} > 72)" >&2
  exit 1
fi

if [[ -n "$body" ]]; then
  while IFS= read -r line; do
    if [[ ${#line} -gt 72 ]]; then
      echo "error: body line is too long (${#line} > 72)" >&2
      exit 1
    fi
  done <<<"$body"
fi

echo "valid: commit message matches the expected format"
