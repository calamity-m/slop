---
name: deliberate
description: Use structured multi-agent deliberation to evaluate 2-4 competing options when tradeoffs are unclear and decision quality matters more than speed. Use this skill when the user asks to deliberate between options, compare multiple viable approaches, or explicitly wants a debate-style decision process.
---

# Deliberate

Spawn opposing sub-agents to argue competing options until one concedes or the debate deadlocks, then hand the standing positions to the user. The user is the arbiter, not the main agent.

This skill is for decisions where multiple approaches look plausible and the tradeoffs are not obvious. It is not for trivial choices, obvious fixes, or low-stakes actions.

## Inputs

- `problem`: the decision to make
- `options`: 2-4 candidate approaches
- `constraints` (optional): requirements, context, preferences, or hard limits

If the user provides more than 4 options, narrow the set before deliberating.

## Sub-agents

- Spawn one sub-agent per option. Each owns and defends a single stance.
- A sub-agent may **concede** (withdraw its option and bow out), but must never adopt a competitor's option as its own.
- Sub-agents argue strongly but acknowledge real weaknesses. No strawmanning the other stances.
- Only spawn sub-agents once the user has explicitly asked to deliberate or debate the options.

## Workflow

1. Confirm the decision fits: 2-4 real options, meaningful uncertainty, enough stakes to justify debate.
2. Normalize the inputs into a short problem statement, a numbered option list, and explicit constraints.
3. **Develop.** Spawn one sub-agent per option. Each builds its case from the shared problem, constraints, and full option list. Give it only its own assigned stance to defend.
4. **Exchange.** Give every still-standing sub-agent the current cases of all the others. Each one then either revises its stance in response or concedes and bows out.
5. **Loop.** Repeat the exchange. Stop when either:
   - **Agreement** — all but one sub-agent has conceded, or
   - **Deadlock** — 3 or more consecutive exchanges pass with no concession and no stance meaningfully moving.
6. Hand the standing positions to the user and let them decide. Do not pick a winner yourself.

## Termination

- The main agent does not arbitrate, score, or break ties. It runs the loop and reports.
- A sub-agent that concedes is out and does not return in later exchanges.
- If only one sub-agent remains standing, that is agreement — report it as the surviving case, not as your verdict.
- If the loop hits deadlock, report every standing position side by side for the user to judge.

## Output Format

Return a concise Markdown summary for the user. No JSON.

When the debate **deadlocked**, present the standing cases for the user to arbitrate:

```md
## Deadlock after <n> exchanges

### <Option A>
- Case: <core argument>
- Strongest point: <best point>
- Concedes: <weakness this side admits>

### <Option B>
- Case: <core argument>
- Strongest point: <best point>
- Concedes: <weakness this side admits>

## Over to you
<one or two sentences naming the crux the user must decide>
```

When the debate reached **agreement**:

```md
## Standing position
<surviving option>

## Why it held
<short paragraph: the case that survived and what made the others concede>

## What was conceded
- <option that bowed out> — <why>

## Reconsider if
- <condition that would reopen the debate>
```

Rules:

- The user is the arbiter. Surface positions; do not declare a winner unless every other stance conceded on its own.
- Keep the output readable in a terminal. Usually 8-16 lines.
- Be concise. Cut scaffolding, not substance.

## Prompting Guidance

When briefing a sub-agent:

- Tell it which option it owns and that it must not switch sides.
- Tell it it may concede and bow out, but may not adopt a competitor's option.
- Tell it to argue strongly, stay concise, and name real risks in its own option.
- On exchanges, tell it to engage the strongest competing case, not a weak version of it.

## Example Triggers

- "Use `deliberate` to choose between these architectures."
- "Run a deliberation on these three game engines."
- "Deliberate Redis vs Postgres for queues."
