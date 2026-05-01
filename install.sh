#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install.sh [--force]

Symlink dotfiles from this repository into $HOME.

Creates:
  ~/.config/skills  -> <repo>/.agents/skills
  ~/.config/agents  -> <repo>/.agents
  ~/.config/nvim    -> <repo>/.config/nvim
  ~/.config/zellij       -> <repo>/.config/zellij
  ~/.config/peanutbutter -> <repo>/.config/peanutbutter
  ~/.config/peanutbutter-private/snippets (directory)

Tool-specific links (skills only):
  ${CLAUDE_HOME:-~/.claude}/skills -> ~/.config/skills
  ${CODEX_HOME:-~/.codex}/skills  -> ~/.config/skills

Also installs:
  forgit -> ${FORGIT_HOME:-~/.local/share/forgit}

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
    *)
      echo "error: unknown flag: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

ensure_symlink() {
  local path="$1"
  local target="$2"

  if [[ -L "$path" ]]; then
    local current
    current="$(readlink "$path")"
    if [[ "$current" == "$target" ]]; then
      log "ok $path -> $target"
      return 0
    fi

    if [[ "$force" -eq 1 ]]; then
      rm -f "$path"
      ln -s "$target" "$path"
      log "relinked $path -> $target"
      return 0
    fi

    warn "skipping $path because it already links to $current (use --force to replace)"
    return 1
  fi

  if [[ -e "$path" ]]; then
    if [[ "$force" -eq 1 ]]; then
      rm -rf "$path"
      ln -s "$target" "$path"
      log "replaced $path with symlink to $target"
      return 0
    fi

    warn "skipping $path because it already exists (use --force to replace)"
    return 1
  fi

  ln -s "$target" "$path"
  log "linked $path -> $target"
}

# Link .config entries into ~/.config
ensure_dir "$HOME/.config" || true
ensure_symlink "$HOME/.config/skills" "$repo_dir/.agents/skills" || true
ensure_symlink "$HOME/.config/agents" "$repo_dir/.agents" || true
ensure_symlink "$HOME/.config/nvim" "$repo_dir/.config/nvim" || true
ensure_symlink "$HOME/.config/zellij" "$repo_dir/.config/zellij" || true
ensure_symlink "$HOME/.config/peanutbutter" "$repo_dir/.config/peanutbutter" || true
ensure_dir "$HOME/.config/peanutbutter-private/snippets" || true

# Symlink ~/.bashrc.d
ensure_symlink "$HOME/.bashrc.d" "$repo_dir/.bashrc.d" || true

# Install shell tools
"$repo_dir/.scripts/install-forgit.sh" || true

# Append bashrc.d sourcing block if not already present
bashrc_marker="# slop:bashrc.d"
if [[ -f "$HOME/.bashrc" ]] && ! grep -qF "$bashrc_marker" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<EOF

$bashrc_marker
if [ -d "\$HOME/.bashrc.d" ]; then
  for config in "\$HOME/.bashrc.d"/*.sh; do
    [ -r "\$config" ] && source "\$config"
  done
fi
EOF
  log "appended bashrc.d sourcing block to ~/.bashrc"
else
  log "ok ~/.bashrc already sources bashrc.d"
fi

# Tool-specific skill symlinks
ensure_dir "$claude_root" || true
ensure_dir "$codex_root" || true
ensure_symlink "$claude_root/skills" "$HOME/.config/skills" || true
ensure_symlink "$codex_root/skills" "$HOME/.config/skills" || true

log ""
log "install complete"
log "  skills: ~/.config/skills -> $repo_dir/.agents/skills"
log "  agents: ~/.config/agents -> $repo_dir/.agents"
log "  nvim:   ~/.config/nvim -> $repo_dir/.config/nvim"
log "  zellij:        ~/.config/zellij -> $repo_dir/.config/zellij"
log "  peanutbutter:  ~/.config/peanutbutter -> $repo_dir/.config/peanutbutter"
log "  peanutbutter private: ~/.config/peanutbutter-private/snippets"
log "  bashrc: ~/.bashrc.d -> $repo_dir/.bashrc.d"
log "  forgit: ${FORGIT_HOME:-$HOME/.local/share/forgit}"
log "  claude: $claude_root/skills -> ~/.config/skills"
log "  codex:  $codex_root/skills -> ~/.config/skills"
