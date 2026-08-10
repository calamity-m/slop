---
name: grill-me
description: Stress-test a plan, design, or change request through a decision-tree interview before implementation. Use when the user says "grill me", "stress-test this plan", "interview me", "challenge this design", asks to surface hidden assumptions, or presents a thin or ambiguous brief.
---

# Grill Me

Interview the user relentlessly until you reach shared understanding. Model the work as a decision tree: each decision is a node; its answer activates, reshapes, or prunes the branches below it.

## Work the frontier

The **frontier** is every unsettled decision whose prerequisites are settled—the questions you can ask now without guessing at earlier answers.

Ask one frontier question at a time. One answer may unlock many branches; add every eligible child to the frontier, then choose the next question. Recompute after every answer. Never follow a fixed questionnaire.

When several questions are eligible, prefer the one that:

1. determines whether large branches matter;
2. most affects the goal, scope, risk, or irreversible choices;
3. unlocks the most downstream decisions.

A question that depends on another unsettled decision is not on the frontier. Do not infer answers for child decisions from their parent.

## Find facts; ask decisions

Finding facts is your job. Read the conversation, supplied documents, repository instructions, relevant code, config, manifests, and history. Use available tools or exploration agents. Never ask the user to inspect a file, run a command, recite documentation, or research something you can establish.

A pending fact blocks only its dependent branches. Work another frontier branch while it is unresolved.

The decisions are the user's. Put every consequential choice to them, even when you have a strong recommendation. Safe, conventional, reversible implementation details may remain agent-owned.

## Ask sharply

Use this format:

```markdown
❓ **Q1** - **<question title>**: <one decision, with concise context and concrete choices>

➡️ <your recommended answer and brief reason>
```

Number questions continuously.

A frontier question may offer several paths, and its answer may spawn many branches. It must still settle one decision. Split unrelated or independently answerable choices into separate nodes.

Prefer precise language, concrete tradeoffs, and decisive recommendations. Avoid broad prompts, throat-clearing, repeated context, and questions whose answers will not change the outcome.

## Grow the tree

Start from the user's request, not a generic checklist. Follow every consequential branch, including where relevant:

- goal and observable success;
- scope and non-goals;
- ambiguous terms;
- hard constraints versus preferences;
- actors and ownership;
- failure, security, and operational risk;
- compatibility, migration, rollout, and reversibility;
- tradeoffs the user must knowingly accept.

After each answer:

1. record it in concrete language;
2. clarify any ambiguity before depending on it;
3. activate relevant branches and prune irrelevant ones;
4. add newly exposed assumptions, conflicts, and decisions;
5. recompute the frontier and ask its highest-impact question.

Relentless means leaving no consequential assumption silent, not manufacturing low-value questions.

## Finish only when empty

The grill is complete when the frontier is empty: every relevant decision is settled or pruned, every required fact is known, and no consequential assumption remains hidden.

Summarize the result:

```markdown
## Shared understanding

- **Goal**: <one sentence>
- **Success**: <observable outcomes>
- **In scope**: <concrete bullets>
- **Out of scope**: <concrete bullets>
- **Key decisions**: <decision and rationale bullets>
- **Terms**: <term = definition>
- **Constraints and assumptions**: <confirmed bullets>
- **Agent-owned choices**: <safe, reversible details, if any>
- **Unresolved**: <items and consequences, or “None”>
```

Then ask one numbered confirmation question in the required format. Do not plan, draft, or implement until the user confirms shared understanding.

If the user stops early, respect it. Summarize the unresolved frontier and its consequences; do not claim completion.
