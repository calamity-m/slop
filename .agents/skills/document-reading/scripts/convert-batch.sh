#!/usr/bin/env bash
# Convert every supported document in a directory to Markdown files.
#
# Usage: convert-batch.sh <input-dir> <output-dir> [extension...]
#   - Extensions default to: docx pptx xlsx pdf html htm csv epub
#   - Output keeps the full input name plus .md (report.pdf -> report.pdf.md)
#     so files that differ only by extension cannot overwrite each other.
#   - A file that fails to convert is reported and skipped; the script
#     continues and exits 1 at the end if anything failed.
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $(basename "$0") <input-dir> <output-dir> [extension...]" >&2
  exit 2
fi

input_dir=$1
output_dir=$2
shift 2
extensions=("$@")
if [[ ${#extensions[@]} -eq 0 ]]; then
  extensions=(docx pptx xlsx pdf html htm csv epub)
fi

if [[ ! -d "$input_dir" ]]; then
  echo "error: input directory not found: $input_dir" >&2
  exit 1
fi
mkdir -p "$output_dir"

# Prefer a real install; fall back to running from the uv cache.
if command -v markitdown >/dev/null 2>&1; then
  runner=(markitdown)
elif command -v uvx >/dev/null 2>&1; then
  runner=(uvx --from "markitdown[all]" markitdown)
else
  echo "error: neither markitdown nor uvx found; run validate-install.sh for install hints" >&2
  exit 1
fi

converted=0
failed=0
for ext in "${extensions[@]}"; do
  for file in "$input_dir"/*."$ext"; do
    [[ -e "$file" ]] || continue
    name=$(basename "$file")
    out="$output_dir/${name}.md"
    if "${runner[@]}" "$file" -o "$out" 2>/dev/null; then
      echo "ok: $file -> $out"
      converted=$((converted + 1))
    else
      echo "failed: $file" >&2
      failed=$((failed + 1))
    fi
  done
done

echo "converted: $converted, failed: $failed" >&2
[[ $failed -eq 0 ]]
