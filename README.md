# slop

AI slop to contain agents, skills, prompts, and other things I use around the place.

Aptly named AI slop.

Why does nobody have a standard for any of these things, forcing me to make a meta repo to contain them?

## Contents

- [Repository layout](#repository-layout)
- [Skills](#skills)
- [Agents](#agents)
- [Copy skills](#copy-skills)

## Repository layout

- `skills/`: reusable skills for repo and user-level agent setups
- `agents/`: local agent definitions and agent-specific docs
- `out/`: generated artifacts and scratch output

## Skills

- [`commit`](./skills/commit/SKILL.md): review local git changes, split them into the smallest coherent commit, and write a clean conventional commit message
- [`edit-helm-chart`](./skills/edit-helm-chart/SKILL.md): edit existing Helm charts and validate the rendered result
- [`grug-review`](./skills/grug-review/SKILL.md): review code and architecture with a simplicity-first bias
- [`init-ai`](./skills/init-ai/SKILL.md): bootstrap a repo for shared AI-agent use with canonical instructions and symlinks
- [`mermaid-sequence-diagram`](./skills/mermaid-sequence-diagram/SKILL.md): create or repair Mermaid sequence diagrams from flows, prose, or code paths
- [`rust-ownership-reviewer`](./skills/rust-ownership-reviewer/SKILL.md): review Rust ownership, borrowing, cloning, allocation, and performance tradeoffs

## Agents

See [`agents/README.md`](./agents/README.md) for the agent-specific index.

- [`grug-brain`](./agents/grug-brain.md): pragmatic code review, refactoring guidance, and architecture advice with a strong bias against unnecessary complexity

## Install skills

Install this repo into a shared config directory and link both Claude and
Codex to the shared `skills/` tree:

```bash
./skills.sh
```

By default that installs into `~/.config/skills/<repo-name>` and creates:

```bash
${CODEX_HOME:-$HOME/.codex}/skills -> ~/.config/skills/<repo-name>/skills
${CLAUDE_HOME:-$HOME/.claude}/skills -> ~/.config/skills/<repo-name>/skills
```

To replace conflicting existing links or paths:

```bash
./skills.sh --force
```
