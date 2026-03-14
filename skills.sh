#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  skills.sh [--force] [install-dir]

Copy this repository into a shared config directory and link tool-specific
user skill directories to the installed shared skills.

Defaults:
  install-dir   $HOME/.config/skills/<repo-name>
  Codex link    ${CODEX_HOME:-$HOME/.codex}/skills -> <install-dir>/skills
  Claude link   ${CLAUDE_HOME:-$HOME/.claude}/skills -> <install-dir>/skills

The script is conservative by default and will not replace existing
non-symlink files or directories unless --force is passed.
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

force=0
install_dir=""

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
      install_dir="$1"
      shift
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"
repo_name="$(basename "$repo_root")"

if [[ -z "$install_dir" ]]; then
  install_dir="$HOME/.config/skills/$repo_name"
fi

install_dir_parent="$(dirname "$install_dir")"
codex_root="${CODEX_HOME:-$HOME/.codex}"
claude_root="${CLAUDE_HOME:-$HOME/.claude}"

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

copy_repo_contents() {
  local source_root="$1"
  local target_root="$2"
  local entry=""

  ensure_dir "$install_dir_parent" || return 1

  if [[ -L "$target_root" || ( -e "$target_root" && ! -d "$target_root" ) ]]; then
    if [[ "$force" -eq 1 ]]; then
      rm -rf "$target_root"
      log "removed conflicting path $target_root"
    else
      warn "skipping install because $target_root already exists and is not a directory"
      return 1
    fi
  fi

  ensure_dir "$target_root" || return 1

  shopt -s dotglob nullglob
  for entry in "$source_root"/*; do
    case "$(basename "$entry")" in
      .git)
        continue
        ;;
    esac

    cp -a "$entry" "$target_root/"
  done
  shopt -u dotglob nullglob

  log "copied repository contents to $target_root"
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

copy_repo_contents "$repo_root" "$install_dir"
ensure_dir "$codex_root" || true
ensure_dir "$claude_root" || true

ensure_symlink "$codex_root/skills" "$install_dir/skills" || true
ensure_symlink "$claude_root/skills" "$install_dir/skills" || true

log "skills install complete"
log "shared install: $install_dir"
log "codex skills: $codex_root/skills"
log "claude skills: $claude_root/skills"
