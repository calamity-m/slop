---
name: learn-session
description: Review the current conversation and propose durable knowledge for AGENTS.md, shared skills/agents, provider-specific docs, or memory. Use at the end of a session to capture what was learned.
---

# Learn Session

Review the current conversation only and extract knowledge worth persisting for future sessions. This is the lightweight counterpart to `learn-history`: do not mine all logs unless the user explicitly asks.

## Hard Rules

- **Read-only until approval.** Do not edit `AGENTS.md`, skills, agent files, or memory until the user approves the proposed changes.
- **Current session only.** Use the conversation available in context. If an active session log path is explicitly available, it may be consulted, but do not scan historical logs.
- **No secrets.** Never persist tokens, private URLs, credentials, customer data, or shell history that looks sensitive. Generalize useful rules that came from sensitive context.
- **No duplicates.** Cross-reference existing documentation before proposing anything.
- **Keep instructions short.** `AGENTS.md` entries should usually be 1-2 lines. Longer workflows belong in a skill or agent doc.

## Process

1. Identify the session arc from the current conversation:
   - What the user asked for.
   - What assumptions or tradeoffs were surfaced.
   - What the user corrected, rejected, or clarified.
   - What was discovered that was non-obvious or expensive.
   - What agent/tooling gap appeared.

2. Read existing persistent knowledge if present:
   - `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.cursor/rules/*`
   - Shared skills/agents: `.agents/skills/*/SKILL.md`, `.agents/agents/*.md`
   - Provider-specific agents/prompts: `.claude/agents/*.md`, `.codex/agents/*.md`, `.pi/agent/prompts/*.md`
   - Memory files discovered under known agent homes, especially:
     - `${CLAUDE_HOME:-$HOME/.claude}/projects/$(printf '%s' "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" | tr '/' '-')/memory/MEMORY.md`
     - `${CODEX_HOME:-$HOME/.codex}/memories/MEMORY.md`
     - `${CODEX_HOME:-$HOME/.codex}/memories/memory_summary.md`
     - `${CODEX_HOME:-$HOME/.codex}/memories/raw_memories.md`

3. Classify each candidate finding into exactly one destination:
   - **`AGENTS.md`** — short repo-wide convention, rule, verification habit, or architectural fact.
   - **Shared skill/agent docs** — reusable workflow or role-specific knowledge under `.agents/skills/` or `.agents/agents/`.
   - **Provider-specific docs** — only when the knowledge applies to one tool, e.g. `.claude/agents/*.md`, `.codex/*`, or `.pi/*`.
   - **Memory** — durable user preference, recurring feedback, or broad project context that should not be a repo rule.
   - **Nowhere** — already documented, too narrow, obvious from source, stale, sensitive, or low ROI.

## What To Look For

Persist candidates when they match at least one signal:

- The user corrected the agent's approach, scope, tone, destination, or tooling choice.
- The user clarified a preference likely to matter in future sessions.
- The session uncovered a non-obvious repo path, config coupling, command, invariant, or verification check.
- A reviewer/tester/subagent missed something that future role instructions should catch.
- The same issue is likely to recur and a short note would prevent rediscovery.

Do **not** persist:

- Details already documented clearly.
- Code-level facts cheaply derivable by reading the source.
- One-off implementation or debugging context.
- A verbose implementation guide masquerading as a rule.
- Anything sensitive unless safely generalized.

## Destination Heuristics

- If every future agent in this repo must follow it, propose `AGENTS.md`.
- If only a specialist role needs it, propose a shared skill/agent doc.
- If it is specific to Claude, Codex, Pi, or another provider, propose the provider-specific doc.
- If it is about the user's preference or long-lived context rather than repository behavior, propose memory.
- If it would not change a future agent's behavior, put it under **Nowhere**.

## Required Output Before Editing

Present a proposal and stop for approval. Use this shape:

```markdown
## Current Session Learning Review

Session summary:
- <brief task arc>

## Proposed persistent knowledge

### AGENTS.md
- <exact proposed wording>  
  Evidence: <where in this conversation it came from and why it should recur>

### Shared skills/agents
- `<path>`: <exact proposed wording or section summary>  
  Evidence: <conversation evidence>

### Provider-specific docs
- `<path>`: <exact proposed wording or section summary>  
  Evidence: <conversation evidence>

### Memory
- <exact proposed wording>  
  Evidence: <conversation evidence>

### Nowhere
- <finding> — <why not persisted>

## Questions / approval
- <any ambiguity>
```

If there are no worthwhile findings, say so plainly and list the main candidates rejected under **Nowhere**.

## Applying Approved Changes

After approval:

1. Re-read the destination files immediately before editing.
2. Apply only the approved changes, with exact minimal edits.
3. Keep `AGENTS.md` concise and avoid reshaping unrelated sections.
4. If creating or moving a shared skill/agent file, ensure any referenced relative paths exist.
5. Verify with concrete checks:
   - `git diff -- AGENTS.md .agents .claude .codex .pi`
   - syntax/format checks for any edited scripts or structured files
   - `test -e <referenced-path>` for new skill references
6. Summarize what was written and what was intentionally left out.
