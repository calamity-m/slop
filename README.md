# slop

AI slop to contain agents, skills, prompts, and other things I use around the place.

Aptly named AI slop.

Why does nobody have a standard for any of these things, forcing me to make a meta repo to contain them?

## Copy skills

Copy repo skills to Claude user skills:

```bash
mkdir -p "$HOME/.claude/skills"
cp -R ./skills/. "$HOME/.claude/skills/"
```

Copy repo skills to Codex user skills:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R ./skills/. "${CODEX_HOME:-$HOME/.codex}/skills/"
```
