# slop

Dumb slop. Dotfiles held together with symlinks and vibes. Neovim config, bash extensions, and a growing pile of AI agent skills

## Quick Start

```bash
git clone <this-repo> ~/code/slop
./install.sh
```

That's it. The script symlinks everything into place:

- `~/.config/skills` — AI agent skills (also wired into `~/.claude/skills` and `~/.codex/skills`)
- `~/.config/agents` — agent instruction files
- `~/.config/nvim` — neovim config
- `~/.bashrc.d` — shell extensions, auto-sourced
- `~/.local/share/forgit` — forgit checkout sourced by `~/.bashrc.d/zz-forgit.sh`

It won't nuke your existing config unless you pass `--force`, at which point you've been warned.

## Why

Because google was a tool once, then stackoverflow, and now this. Why not slop it together with my actual dotfiles?
