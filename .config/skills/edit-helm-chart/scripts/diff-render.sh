#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  diff-render.sh <chart-dir> [helm args...]

Examples:
  diff-render.sh ./charts/myapp
  diff-render.sh ./charts/myapp -f values-prod.yaml
  diff-render.sh ./charts/myapp --set image.tag=abc123

Render the chart from HEAD and from the working tree with the same inputs, then
print a unified diff of the rendered manifests. Additional arguments are
forwarded to both `helm template` commands.
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

if ! command -v diff >/dev/null 2>&1; then
  echo "error: diff is not available" >&2
  exit 127
fi

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is not available" >&2
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

chart_abs="$(cd "$chart_dir" && pwd -P)"

if ! repo_root="$(git -C "$chart_abs" rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: chart directory is not inside a git repository: $chart_dir" >&2
  exit 2
fi

case "$chart_abs" in
  "$repo_root")
    chart_rel="."
    ;;
  "$repo_root"/*)
    chart_rel="${chart_abs#"$repo_root"/}"
    ;;
  *)
    echo "error: failed to compute chart path relative to repository root" >&2
    exit 1
    ;;
esac

if ! git -C "$repo_root" rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "error: repository has no HEAD commit yet" >&2
  exit 2
fi

if [[ "$chart_rel" == "." ]]; then
  head_chart_spec="HEAD:Chart.yaml"
else
  head_chart_spec="HEAD:$chart_rel/Chart.yaml"
fi

if ! git -C "$repo_root" cat-file -e "$head_chart_spec" 2>/dev/null; then
  echo "error: chart does not exist at HEAD: $chart_rel" >&2
  exit 2
fi

extra_args=("$@")
workdir="$(mktemp -d)"
cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT

head_tree_dir="$workdir/head-tree"
mkdir -p "$head_tree_dir"

if [[ "$chart_rel" == "." ]]; then
  git -C "$repo_root" archive --format=tar HEAD | tar -xf - -C "$head_tree_dir"
  head_chart_dir="$head_tree_dir"
else
  git -C "$repo_root" archive --format=tar HEAD "$chart_rel" | tar -xf - -C "$head_tree_dir"
  head_chart_dir="$head_tree_dir/$chart_rel"
fi

before_output="$workdir/head.yaml"
after_output="$workdir/working-tree.yaml"
release_name="render-diff"

echo "==> helm template $release_name $head_chart_dir ${extra_args[*]}"
helm template "$release_name" "$head_chart_dir" "${extra_args[@]}" >"$before_output"

echo "==> helm template $release_name $chart_dir ${extra_args[*]}"
helm template "$release_name" "$chart_dir" "${extra_args[@]}" >"$after_output"

set +e
diff -u "$before_output" "$after_output"
diff_status=$?
set -e

if [[ $diff_status -eq 0 ]]; then
  echo "no rendered manifest changes"
  exit 0
fi

if [[ $diff_status -eq 1 ]]; then
  echo "rendered manifests differ between HEAD and the working tree"
  exit 0
fi

echo "error: diff failed" >&2
exit 1
