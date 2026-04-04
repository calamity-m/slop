---
name: deliberate
description: Use structured multi-agent deliberation to evaluate 2-4 competing options when tradeoffs are unclear and decision quality matters more than speed. Use this skill when the user asks to deliberate between options, compare multiple viable approaches, or explicitly wants a debate-style decision process.
---

# Deliberate

Use structured multi-agent deliberation to choose between 2-4 viable options.

This skill is for decisions where multiple approaches look plausible and the tradeoffs are not obvious. It is not for trivial choices, obvious fixes, or low-stakes actions.

## Inputs

- `problem`: the decision to make
- `options`: 2-4 candidate approaches
- `constraints` (optional): requirements, context, preferences, or hard limits
- `rounds` (optional): default `2`, max `5`

If the user does not provide `rounds`, use `2`.
If the user provides more than `5` rounds, cap it at `5`.
If the user provides more than 4 options, narrow the set before deliberating.

## Roles

### Advocates

- Create one advocate per option.
- Each advocate must strongly defend only its assigned option.
- Advocates must not switch sides.
- Advocates may withdraw support from their own option, but must not adopt another option as their own.
- Advocates should acknowledge weaknesses honestly.

### Arbiter

- The main agent is the arbiter.
- The arbiter checks for quorum after each round and uses one consistent rubric only if a deadlock remains.
- The arbiter is a tie breaker, not an extra advocate.
- The arbiter must not invent new options.

## Workflow

1. Confirm the decision fits this skill: 2-4 real options, meaningful uncertainty, and enough stakes to justify debate.
2. Normalize the inputs into a short problem statement, a numbered option list, explicit constraints, and `rounds`.
3. Spawn one sub-agent per option. Use `spawn_agent` only when the user has explicitly asked to deliberate, compare via debate, or otherwise requested multi-agent reasoning.
4. Give each advocate only its assigned option, the shared problem, the shared constraints, and the full option list for comparison.
5. Require each advocate to complete Phase 1 and the first critique pass in a concise structured response.
6. Continue the back-and-forth critique and revision cycle until quorum is reached or the round limit is hit.
7. Treat quorum as reached when exactly one advocate still returns `position: yes` for its own option and all other advocates have withdrawn support with `position: no`.
8. If no quorum is reached by the final round, arbitrate locally as a tie breaker. Score the remaining contenders against:
   - correctness
   - simplicity
   - risk
   - reversibility
   - effort
   - alignment with constraints
9. Return the final result in the exact JSON shape below.

## Advocate Output Contract

For Phase 1, each advocate must produce:

```json
{
  "option": "<assigned option>",
  "thesis": "<why this option is best>",
  "arguments": ["<strong point 1>", "<strong point 2>"],
  "assumptions": ["<what must be true>"],
  "risks": ["<biggest downside>"]
}
```

For Phase 2, each advocate must add:

```json
{
  "strongest_competitor": "<best competing option>",
  "critique": ["<weakness in that competing option>"],
  "self_flaws": ["<weakness in this advocate's own case>"]
}
```

For each revision round after the initial pass, each advocate must add:

```json
{
  "position": "yes | no",
  "confidence": "low | medium | high",
  "revised_reasoning": ["<updated reasoning>"]
}
```

## Arbiter Rules

- Default to letting the advocates converge on a winner without intervention.
- Apply the same criteria to every option only when quorum is not reached.
- Prefer the option that best fits the stated constraints, not the most interesting option.
- Treat reversibility as a major tie-breaker when correctness is close.
- Keep the reasoning concise and decision-focused.
- If the evidence is weak or constraints are underspecified, lower confidence rather than over-claiming.

## Output Format

Return exactly this JSON shape:

```json
{
  "decision": "<winning option>",
  "reasoning": "<why it won>",
  "runner_up": "<second best option>",
  "tradeoffs": ["<key tradeoff 1>", "<key tradeoff 2>"],
  "risks": ["<risk 1>", "<risk 2>"],
  "confidence": "low | medium | high",
  "when_to_reconsider": ["<condition that would change decision>"]
}
```

## Modes

### `binary`

- Use exactly 2 options.
- Keep the debate shorter and faster.

### `multi`

- Use 3-4 options.
- Run the full workflow.

### `redteam`

- Use three roles:
  - one proposes
  - one attacks
  - one defends the revised version
- Use this when the user wants a stress test of a favored option rather than a balanced comparison.

## Prompting Guidance

When briefing advocates:

- Tell them which option they own.
- Tell them they must not switch sides.
- Tell them they may stop recommending their own option, but may not adopt a competitor's option as their own.
- Tell them to be concise.
- Tell them to argue strongly but acknowledge real risks.
- Tell them to identify the strongest competing option, not a weak strawman.

When arbitrating:

- First check whether quorum was already reached.
- Summarize each option's best case and biggest weakness.
- Break ties using the explicit rubric.
- Do not synthesize a hybrid option unless the user separately asks for one after the deliberation.

## Example Triggers

- "Use `deliberate` to choose between these architectures."
- "Run a 3-option deliberation on game engines."
- "Deliberate (binary) on Redis vs Postgres for queues."
