#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  validate.sh <chart-dir> [helm args...]

Examples:
  validate.sh ./charts/myapp
  validate.sh ./charts/myapp -f values-prod.yaml
  validate.sh ./charts/myapp --set image.tag=abc123

Validate a Helm chart by running:
  1. helm lint
  2. helm template

Any extra arguments are forwarded to both commands.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "error: helm is not available" >&2
  exit 127
fi

chart_dir="$1"
shift

if [[ ! -d "$chart_dir" ]]; then
  echo "error: chart directory not found: $chart_dir" >&2
  exit 2
fi

if [[ ! -f "$chart_dir/Chart.yaml" ]]; then
  echo "error: Chart.yaml not found in: $chart_dir" >&2
  exit 2
fi

extra_args=("$@")
release_name="validation-release"

echo "==> helm lint $chart_dir ${extra_args[*]}"
helm lint "$chart_dir" "${extra_args[@]}"

echo "==> helm template $release_name $chart_dir ${extra_args[*]}"
helm template "$release_name" "$chart_dir" "${extra_args[@]}" >/dev/null

echo "valid: helm lint and helm template both succeeded"
