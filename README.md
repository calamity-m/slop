# slop

Dumb slop. Dotfiles held together with symlinks and vibes. Neovim config, bash extensions, and a growing pile of AI agent skills

## Quick Start

```bash
git clone <this-repo> ~/code/slop
./install.sh
```

That's it. The script symlinks everything into place. If `mise` is available, it'll install the binaries required too.

## Skills

Skills are authored categorized under `.skills/<category>/<skill>/`, but agents read them flat
from `~/.agents/skills/<skill>`. Every interactive Bash start reconciles the two, so adding,
removing, renaming, or moving a skill between categories needs no `install.sh` rerun — just a
new shell, or `~/.scripts/sync-agent-skills` to pick it up mid-session.

Only links pointing into `.skills` are managed; anything else you drop in `~/.agents/skills`
is left alone, and a name used by two categories is reported rather than guessed at.

## Mise

```bash
mise install
mise upgrade
```

The checked-in mise config is intentionally limited to binary tools.

## Why

Because google was a tool once, then stackoverflow, and now this. Why not slop it together with my actual dotfiles?
