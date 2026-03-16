# slop

AI slop to contain agents, skills, prompts, and other things I use around the place.

Aptly named AI slop.

Why does nobody have a standard for any of these things, forcing me to make a meta repo to contain them?

## Contents

- [Repository layout](#repository-layout)
- [Skills](#skills)
- [Agents](#agents)
- [Install](#install)

## Repository layout

- `.config/skills/`: reusable skills for repo and user-level agent setups
- `.config/agents/`: agent definitions and agent-specific docs
- `.config/nvim/`: neovim configuration

## Skills

- [`commit`](./.config/skills/commit/SKILL.md): review local git changes, split them into the smallest coherent commit, and write a clean conventional commit message
- [`edit-helm-chart`](./.config/skills/edit-helm-chart/SKILL.md): edit existing Helm charts and validate the rendered result
- [`grug-review`](./.config/skills/grug-review/SKILL.md): review code and architecture with a simplicity-first bias
- [`init-ai`](./.config/skills/init-ai/SKILL.md): bootstrap a repo for shared AI-agent use with canonical instructions and symlinks
- [`mermaid-sequence-diagram`](./.config/skills/mermaid-sequence-diagram/SKILL.md): create or repair Mermaid sequence diagrams from flows, prose, or code paths
- [`rust-ownership-reviewer`](./.config/skills/rust-ownership-reviewer/SKILL.md): review Rust ownership, borrowing, cloning, allocation, and performance tradeoffs

## Agents

See [`.config/agents/README.md`](./.config/agents/README.md) for the agent-specific index.

- [`grug-brain`](./.config/agents/grug-brain.md): pragmatic code review, refactoring guidance, and architecture advice with a strong bias against unnecessary complexity

## Install

Clone this repo and run the install script to symlink everything into place:

```bash
git clone <this-repo> ~/code/slop
cd ~/code/slop
./install.sh
```

This creates symlinks so edits in the repo are immediately reflected:

```
~/.config/skills -> <repo>/.config/skills
~/.config/agents -> <repo>/.config/agents
~/.config/nvim   -> <repo>/.config/nvim
~/.claude/skills -> ~/.config/skills
~/.codex/skills  -> ~/.config/skills
```

To replace conflicting existing links or paths:

```bash
./install.sh --force
```
