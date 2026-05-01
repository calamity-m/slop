#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  validate.sh <diagram-file>
  validate.sh -    # read Mermaid source from stdin

Validate a Mermaid diagram by asking Mermaid CLI to render it via `npx`.
Supported diagram types: sequenceDiagram, flowchart, graph, erDiagram.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

workdir="$(mktemp -d)"
cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT

input_file="$workdir/input.mmd"
output_file="$workdir/output.svg"

if [[ $# -eq 0 || "${1:-}" == "-" ]]; then
  if [[ -t 0 ]]; then
    echo "error: provide a file path or pipe Mermaid source on stdin" >&2
    exit 2
  fi
  cat >"$input_file"
else
  if [[ ! -f "$1" ]]; then
    echo "error: file not found: $1" >&2
    exit 2
  fi
  cp "$1" "$input_file"
fi

# Detect diagram type
diagram_type=""
if grep -Eq '^[[:space:]]*sequenceDiagram([[:space:]]|$)' "$input_file"; then
  diagram_type="sequence"
elif grep -Eq '^[[:space:]]*erDiagram([[:space:]]|$)' "$input_file"; then
  diagram_type="erd"
elif grep -Eq '^[[:space:]]*(flowchart|graph)[[:space:]]' "$input_file"; then
  diagram_type="flowchart"
fi

if [[ -z "$diagram_type" ]]; then
  echo "error: input does not appear to be a supported Mermaid diagram type" >&2
  echo "Supported types: sequenceDiagram, flowchart, graph, erDiagram" >&2
  exit 1
fi

run_npx_mmdc() {
  npx -y @mermaid-js/mermaid-cli -q -i "$input_file" -o "$output_file"
}

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx is not available" >&2
  exit 127
fi

runner="npx @mermaid-js/mermaid-cli"

if run_npx_mmdc; then
  echo "valid: Mermaid CLI rendered the $diagram_type diagram successfully with $runner"
  exit 0
fi

echo "error: Mermaid CLI failed to render the $diagram_type diagram via $runner" >&2
exit 1
