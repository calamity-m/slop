---
name: learn-session
description: Review the current conversation and propose durable knowledge for AGENTS.md, shared skills/agents, or provider-specific docs and config such as hooks. Use when the user says "learn session", "capture this session", or asks what should be persisted from the current conversation.
---

# Learn Session

Review the conversation currently in context and extract knowledge worth persisting for future sessions. Work only from what is already in context; do not scan session logs or history. If the user explicitly provides a session log path, that single file may be read — nothing else.

## Hard Rules

- **Read-only until approval.** Do not edit `AGENTS.md`, skills, agent files, or provider config until the user approves the proposed changes.
- **No secrets.** Never persist tokens, private URLs, credentials, customer data, or shell history that looks sensitive. Generalize useful rules that came from sensitive context.
- **No duplicates.** Check the relevant existing documentation before proposing anything.
- **Few, high-value proposals.** Rank candidates by expected recurrence and propose the strongest — typically five or fewer. Borderline candidates default to **Nowhere**.
- **Keep instructions short.** `AGENTS.md` entries should usually be 1-2 lines. Longer workflows belong in a skill or agent doc.

## Process

1. Identify candidate findings from the current conversation:
   - What the user asked for.
   - What assumptions or tradeoffs were surfaced.
   - What the user corrected, rejected, or clarified.
   - What was discovered that was non-obvious or expensive.
   - What agent/tooling gap appeared.

2. For each candidate, read only the existing files relevant to that candidate to rule out duplication and pick a destination. Do not sweep every knowledge file up front. Depending on the candidate, that means some of:
   - `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.cursor/rules/*`
   - Shared skills/agents: `.agents/skills/*/SKILL.md`, `.agents/agents/*.md`
   - Provider-specific docs and config: `.claude/agents/*.md`, `.claude/settings.json` (hooks), `.codex/agents/*.md`, `.pi/agent/prompts/*.md`

3. Classify each candidate into exactly one destination:
   - **`AGENTS.md`** — short repo-wide convention, rule, verification habit, or architectural fact. Name the target section.
   - **Shared skill/agent docs** — reusable workflow or role-specific knowledge under `.agents/skills/` or `.agents/agents/`, as a new skill or an adaptation of an existing one.
   - **Provider-specific docs/config** — knowledge or automation that applies to one tool, e.g. `.claude/agents/*.md`, a hook in `.claude/settings.json`, `.codex/*`, or `.pi/*`.
   - **Nowhere** — already documented, too narrow, obvious from source, stale, sensitive, or low ROI.

## What To Look For

Persist candidates when they match at least one signal:

- The user corrected the agent's approach, scope, tone, destination, or tooling choice.
- The user steered the agent's line of thinking directly.
- The user clarified a working preference that should become a repo rule or a skill adjustment.
- The session uncovered a non-obvious repo path, config coupling, command, invariant, or verification check.
- A reviewer/tester/subagent missed something that future role instructions should catch.
- A behavior the user wants automated every time — a candidate for a hook rather than an instruction.
- The same issue is likely to recur and a short note would prevent rediscovery.

Do **not** persist:

- Details already documented clearly.
- Code-level facts cheaply derivable by reading the source.
- One-off implementation or debugging context.
- A verbose implementation guide masquerading as a rule.
- Anything sensitive unless safely generalized.

## Destination Heuristics

- If every future agent in this repo must follow it, propose `AGENTS.md`.
- If only a specialist role or workflow needs it, propose a shared skill/agent doc.
- If it is specific to Claude, Codex, Pi, or another provider, propose the provider-specific doc.
- If it is an automated "always do X before/after Y" behavior, propose a hook in the provider's settings rather than an instruction an agent might skip.
- If it would not change a future agent's behavior, put it under **Nowhere**.

## Required Output Before Editing

Present a proposal and stop for approval. Every proposal must contain the exact text or config to be written — never a summary of what would be written. Omit destination sections with no entries. Use this shape:

```markdown
## Current Session Learning Review

Session summary:

- <brief task arc>

## Proposed persistent knowledge

### AGENTS.md

- Target section: <section>
  - Proposed text: <exact proposed wording>
  - Evidence: <where in this conversation it came from and why it should recur>

### Shared skills/agents

- `<path>` (<new skill | edit>)
  - Proposed text: <exact proposed wording or diff>
  - Evidence: <conversation evidence>

### Provider-specific docs/config

- `<path>` (<doc edit | hook>)
  - Proposed text: <exact proposed wording, or the exact hook JSON>
  - Evidence: <conversation evidence>

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
   - JSON validity for any edited settings/hook file (e.g. `jq . .claude/settings.json`)
   - syntax/format checks for any other edited scripts or structured files
   - `test -e <referenced-path>` for new skill references
   - re-read any edited file that lives outside the repo, since `git diff` will not show it
6. Summarize what was written and what was intentionally left out.
