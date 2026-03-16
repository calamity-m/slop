#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  init-repo.sh [--force] [repo-root]

Initialize a repository for shared AI-agent use by creating:
  - AGENTS.md from the bundled template when missing
  - CLAUDE/GEMINI aliases pointing to AGENTS.md
  - .skills/ as the canonical shared skill directory
  - .claude/.codex/.gemini/.opencode skill aliases to .skills
  - optional agent directory aliases when ./agents exists

The script is conservative by default and will not replace existing
non-symlink files or directories unless --force is passed.
EOF
}

force=0
repo_root="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown flag: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      repo_root="$1"
      shift
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template_path="$script_dir/../assets/AGENTS.md.template"
repo_root="$(cd "$repo_root" && pwd)"

tool_dirs=(".claude" ".codex" ".gemini" ".opencode")
agent_aliases=("CLAUDE.md" "GEMINI.md" "CLAUDE.MD" "GEMINI.MD")

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

ensure_dir() {
  local path="$1"

  if [[ -d "$path" ]]; then
    return 0
  fi

  if [[ -e "$path" ]]; then
    warn "skipping directory creation for $path because a non-directory already exists"
    return 1
  fi

  mkdir -p "$path"
  log "created directory $path"
}

install_template_if_missing() {
  local target="$1"

  if [[ -e "$target" ]]; then
    log "kept existing $target"
    return 0
  fi

  cp "$template_path" "$target"
  log "created $target from template"
}

ensure_symlink() {
  local path="$1"
  local target="$2"

  if [[ -L "$path" ]]; then
    local current
    current="$(readlink "$path")"
    if [[ "$current" == "$target" ]]; then
      log "kept existing symlink $path -> $target"
      return 0
    fi

    if [[ "$force" -eq 1 ]]; then
      rm -f "$path"
      ln -s "$target" "$path"
      log "relinked $path -> $target"
      return 0
    fi

    warn "skipping $path because it already links to $current"
    return 1
  fi

  if [[ -e "$path" ]]; then
    if [[ "$force" -eq 1 ]]; then
      rm -rf "$path"
      ln -s "$target" "$path"
      log "replaced $path with symlink to $target"
      return 0
    fi

    warn "skipping $path because it already exists"
    return 1
  fi

  ln -s "$target" "$path"
  log "linked $path -> $target"
}

install_template_if_missing "$repo_root/AGENTS.md"
ensure_dir "$repo_root/.skills" || true

for alias_name in "${agent_aliases[@]}"; do
  ensure_symlink "$repo_root/$alias_name" "AGENTS.md" || true
done

for tool_dir in "${tool_dirs[@]}"; do
  ensure_dir "$repo_root/$tool_dir" || continue
  ensure_symlink "$repo_root/$tool_dir/skills" "../.skills" || true
done

if [[ -d "$repo_root/agents" ]]; then
  for tool_dir in "${tool_dirs[@]}"; do
    ensure_dir "$repo_root/$tool_dir" || continue
    ensure_symlink "$repo_root/$tool_dir/agents" "../agents" || true
  done
else
  log "skipped agent directory aliases because $repo_root/agents does not exist"
fi

log "init-ai bootstrap complete for $repo_root"
