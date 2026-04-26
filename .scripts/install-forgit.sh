#!/usr/bin/env bash

set -euo pipefail

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

repo_url="https://github.com/wfxr/forgit.git"
install_dir="${FORGIT_HOME:-$HOME/.local/share/forgit}"

if ! command -v git >/dev/null 2>&1; then
  warn "skipping forgit install because git is not available"
  exit 0
fi

if [[ -d "$install_dir/.git" ]]; then
  log "ok forgit already cloned at $install_dir"
  exit 0
fi

if [[ -e "$install_dir" ]]; then
  warn "skipping forgit install because $install_dir already exists and is not a git checkout"
  exit 0
fi

mkdir -p "$(dirname "$install_dir")"
git clone --depth 1 "$repo_url" "$install_dir"
log "cloned forgit to $install_dir"
