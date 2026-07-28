#!/usr/bin/env bash
# Verify that markitdown can run on this machine and report how it will be invoked.
# Exits 0 and prints the runner command when usable; exits 1 with install hints otherwise.
set -euo pipefail

if command -v markitdown >/dev/null 2>&1; then
  echo "runner: markitdown (on PATH at $(command -v markitdown))"
  echo "version: $(markitdown --version)"
  exit 0
fi

if command -v uvx >/dev/null 2>&1; then
  # First run downloads markitdown[all] into the uv cache; later runs are instant.
  if version=$(uvx --from "markitdown[all]" markitdown --version 2>/dev/null); then
    echo "runner: uvx --from \"markitdown[all]\" markitdown"
    echo "version: ${version}"
    exit 0
  fi
  echo "error: uvx is available but failed to run markitdown (network or cache issue?)" >&2
  echo "try: uvx --from \"markitdown[all]\" markitdown --version" >&2
  exit 1
fi

echo "error: neither markitdown nor uvx found on PATH" >&2
echo "install one of:" >&2
echo "  uv tool install \"markitdown[all]\"   # persistent CLI via uv" >&2
echo "  pipx install \"markitdown[all]\"      # persistent CLI via pipx" >&2
echo "  pip install \"markitdown[all]\"       # into the active environment" >&2
exit 1
