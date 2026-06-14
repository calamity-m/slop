---
description: Debug an issue through a disciplined hypothesis-elimination loop backed by a persistent plan document
argument-hint: "<issue-description> [known-leads]"
---

You are being tasked with debugging this issue, plus any known leads the user included:

```text
$ARGUMENTS
```

The issue may be a crash, a wrong result, a flaky test, a performance regression, a hang, a build failure, or any other observed misbehavior. The known leads may be files, symbols, stack traces, error messages, commands, failing tests, recent commits, or notes the user already believes are relevant.

Your goal is to find and fix the root cause through a structured loop, not to guess at fixes. You eliminate hypotheses one at a time, each against a stated verification method, and you record everything in a persistent plan document so the investigation survives across turns and context resets.

## 1. Understand the problem

Do not start forming fixes until you can state the problem precisely. Establish:

- the exact observed behavior and the expected behavior
- how to reproduce it (command, steps, inputs, environment)
- when it started, if known, and what changed around then
- the blast radius: always vs. intermittent, one environment vs. all

If any of this is missing or ambiguous enough to risk wasting a loop, **stop and grill the user**. Ask pointed, specific questions rather than proceeding on assumptions. Do not invent a reproduction you have not confirmed.

## 2. Create the plan document

Pick a short kebab-case slug for the issue (e.g. `login-500`, `flaky-auth-test`, `slow-dashboard`). Write the investigation to:

```text
.pi/plans/debug/{issue}.md
```

Create the `.pi/plans/debug/` directory if it does not exist. If a document for this issue already exists, read it first and continue from where it left off rather than starting over.

Use this structure:

```markdown
# Debug: {issue}

## Problem

- Observed: ...
- Expected: ...
- Reproduction: ...
- Started / changed: ...
- Scope: ...

## Verification method

How a fix (or a hypothesis) is confirmed or rejected: a test command, a manual
check, a log line, a metric, user feedback. State the exact command or steps.

## Hypotheses

### H1 — <short name> — [open | testing | confirmed | eliminated]

- Rationale: why this is plausible given the evidence
- Prediction: what must be true if this is the cause
- Test: how to confirm or eliminate it
- Result: (filled in after testing — what happened, why it was kept or ruled out)

## Timeline

- A running log of what was tried and learned, newest last.
```

Keep this document current. It is the source of truth for the investigation.

## 3. Develop hypotheses

From the evidence and your reading of the code, list concrete, falsifiable hypotheses for the root cause. Prefer ones the current evidence most supports. For each, write down the rationale and a prediction that would be true _only if_ that hypothesis is correct. Avoid vague hypotheses you cannot test.

## 4. Establish the verification method

Before changing anything, decide how you will know whether a hypothesis is right. Focus on reproduction of the issue before saying a fix is working. Prefer, in order:

1. an automated test that reproduces the bug, which only pass one the issue is fixed
2. a concrete manual check with exact steps and expected output
3. user feedback, when the first two are not possible

Where reasonable, write the failing test first so the fix has a target. Record the method in the plan document.

## 5. Select a hypothesis and act

Pick the single highest-value open hypothesis. Mark it `testing`. Then:

- Make the **smallest targeted change** that tests it. Do not bundle unrelated edits or speculative refactors.
- Run the verification method.
- If it resolves the issue and the verification passes: mark the hypothesis `confirmed`, keep the fix, and report.
- If it does not: mark the hypothesis `eliminated`, record in `Result` exactly what happened and why it was ruled out, and **revert the failed change** unless it is an unambiguous improvement worth keeping. Do not leave dead experimental edits behind.

## 6. Refine the hypothesis set

Fold what you learned back into the document. Eliminating a hypothesis usually sharpens or spawns others — add the new ones, drop the ones the latest evidence kills, and re-rank what remains.

## 7. Loop

Repeat steps 3–6 until the issue is confirmed fixed and verified, or until every hypothesis is eliminated. If you eliminate all hypotheses without a fix, stop and report: summarize what was ruled out, what the evidence now points to, and what additional information or access you need from the user. Do not keep guessing past the evidence.

Throughout: prefer verified facts over speculation, keep changes minimal and reversible, and keep the plan document accurate so the work can be resumed at any point.
