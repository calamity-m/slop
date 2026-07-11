#!/usr/bin/env bash
# Convert one document to Markdown with markitdown.
#
# Usage: convert.sh <input-file> [output.md] [extra markitdown args...]
#   - Without output.md, Markdown is written to stdout.
#   - Extra args are passed straight to markitdown (e.g. --keep-data-uris,
#     -x .docx to hint the format of an oddly named file).
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $(basename "$0") <input-file> [output.md] [extra markitdown args...]" >&2
  exit 2
fi

input=$1
shift
if [[ ! -f "$input" ]]; then
  echo "error: input file not found: $input" >&2
  exit 1
fi

# Prefer a real install; fall back to running from the uv cache.
if command -v markitdown >/dev/null 2>&1; then
  runner=(markitdown)
elif command -v uvx >/dev/null 2>&1; then
  runner=(uvx --from "markitdown[all]" markitdown)
else
  echo "error: neither markitdown nor uvx found; run validate-install.sh for install hints" >&2
  exit 1
fi

# Treat a first arg that doesn't start with '-' as the output file.
if [[ $# -ge 1 && $1 != -* ]]; then
  output=$1
  shift
  "${runner[@]}" "$input" -o "$output" "$@"
  echo "wrote: $output" >&2
else
  "${runner[@]}" "$input" "$@"
fi
