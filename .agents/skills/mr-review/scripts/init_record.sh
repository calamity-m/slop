#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: init_record.sh [--provider NAME] [--review ID_OR_URL] [--base BRANCH] [--branch BRANCH]

Create or reuse a provider-neutral MR review record under /tmp/mr-review.
USAGE
}

provider="unknown"
review=""
base=""
branch=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --provider)
      provider="${2:?missing value for --provider}"
      shift 2
      ;;
    --review)
      review="${2:?missing value for --review}"
      shift 2
      ;;
    --base)
      base="${2:?missing value for --base}"
      shift 2
      ;;
    --branch)
      branch="${2:?missing value for --branch}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
repo_name="$(basename "$repo_root")"
current_branch="$(git -C "$repo_root" branch --show-current 2>/dev/null || true)"
head_sha="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || true)"

if [ -z "$branch" ]; then
  branch="${current_branch:-unknown}"
fi

if [ -z "$review" ]; then
  review="$branch"
fi

safe_id="$(printf '%s-%s' "$repo_name" "$review" | tr -c '[:alnum:]_.-' '-')"
dir="/tmp/mr-review"
path="$dir/$safe_id.md"

mkdir -p "$dir"

if [ ! -f "$path" ]; then
  cat > "$path" <<EOF
# MR Review State

Target:
- Provider: $provider
- Review: $review
- Repository: $repo_root
- Branch: $branch
- Base: ${base:-unknown}
- Head SHA: ${head_sha:-unknown}

Context:
- Title/description understanding:
- Linked data:
- Open threads:
- Pre-diff repo guidance:

Code understanding:
- MR changes:
- Existing base behavior:
- Affected areas:
- Tests and verification:

Review pass:
- General observations:
- Code-quality findings:
- Subagent findings:
- Questions:

Comments:
- To post:
- Posted:
- Skipped with reason:

Next step:
- Review the title, description, linked data, and open threads before opening the MR diff.
EOF
fi

printf '%s\n' "$path"
