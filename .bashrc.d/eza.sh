# Long format with headers and icons
alias ll='eza -l --header --icons'

# Long format including hidden files
alias la='eza -la --header --icons'

# Muscle-memory compatibility for `ls -lsha`.
unalias ls 2>/dev/null || true
ls() {
  if [[ ${1-} == "-lsha" ]]; then
    shift
    eza -laS --header --icons "$@"
  else
    command ls "$@"
  fi
}

# Tree view shortcut
alias tree='eza --tree'
