---
name: Tmux
tags:
  - cli
  - terminal
  - tmux
variables:
  session:
    command: "tmux list-sessions -F '#{session_name}' 2>/dev/null"
---

# Tmux Snippets

Snippets for inspecting and diagnosing a tmux setup

## List installed tmux plugins

Compare the plugins declared in `tmux.conf` against what TPM actually cloned to disk. Use this when a plugin's keybinding silently falls back to a tmux default: TPM hides clone failures behind `>/dev/null 2>&1`, so `prefix + I` looks successful even when nothing downloaded. A missing `tpm` itself is worse — the `if-shell` guard in `tmux.conf` skips TPM entirely and `prefix + I` becomes a dead key.

```bash
conf="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
dir="$(tmux start-server \; show-environment -g TMUX_PLUGIN_MANAGER_PATH 2>/dev/null | cut -d= -f2-)"
dir="${dir:-$HOME/.tmux/plugins}"

echo "conf: $conf"
echo "dir:  $dir"
echo
if [ -x "$dir/tpm/tpm" ]; then echo "ok       tpm"; else echo "MISSING  tpm (prefix + I is unbound without it)"; fi
awk '/^[ \t]*set(-option)? +-g +@plugin/ { gsub(/["'\'']/, ""); print $4 }' "$conf" |
  while read -r plugin; do
    name="${plugin##*/}"
    name="${name%.git}"
    if [ -d "$dir/$name/.git" ]; then echo "ok       $plugin"; else echo "MISSING  $plugin"; fi
  done
```

## Attach to an existing session

Attach to a running tmux session by name. Inside tmux, `attach-session` refuses to nest, so this switches the current client to the target session instead.

```bash
if [ -n "$TMUX" ]; then tmux switch-client -t <@session>; else tmux attach-session -t <@session>; fi
```
