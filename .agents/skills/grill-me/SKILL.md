---
name: grill-me
description: Stress-test a plan, design, or change request through structured sequential interviewing before any implementation begins. Use this skill whenever the user says "grill me", "stress-test this plan", "interview me", "challenge this design", asks you to surface hidden assumptions, or wants a critical pre-implementation check on what they have described. Also use it as a pre-draft step inside other planning skills (e.g. `bigplan`) when the brief is thin or ambiguous.
---

# Grill Me

## What this skill is for

Four goals, in this order:

1. **Reach shared understanding.** You and the user describe the same system in the same words.
2. **Unearth hidden assumptions.** Anything the user is taking for granted that you would not, or vice versa.
3. **Nail down terminology and language.** Make sure overloaded words ("user", "session", "job", "service", "client") mean one specific thing in the context of this work.
4. **Separate need from want.** What is required for the work to succeed vs. what would be nice to have.

A grilling that does not move the needle on at least one of these is a bad grilling.

## What this skill is **not** for

Do not ask questions whose answers can be obtained by:

- Reading the repository's `README.md`, `AGENTS.md`/`CLAUDE.md`, or visible config files.
- Running a quick `ls`, `find`, or `git log` against the repo.
- Opening one or two source files at the obvious entry point.
- Checking lock/manifest files for language, framework, package versions.
- Reading any document the user already linked in the conversation.

If the answer is in the repo or in a doc that has been mentioned, **find it yourself** before grilling. Asking the user to recite their own README wastes their time and erodes trust in the skill.

When in doubt: do the cheapest available exploration first, then grill on what's left.

## Pre-flight (always)

Before asking the first question:

1. Read the repo orientation files (`README.md`, `AGENTS.md`, any `BIGPLAN.md`).
2. Run a quick directory survey — top-level layout, the relevant subdirectory, manifest/lock files for tech stack.
3. Note any document or URL the user has already shared in this conversation.
4. Build a short internal list of:
   - **Knowns** — facts you have established from the above.
   - **Unknowns worth asking** — gaps that genuinely require the user to decide or disclose.
   - **Assumptions you are tempted to make** — these are the prime candidates for grilling, since the user can confirm or correct them.

Skip the grill entirely if everything important is already explicit and consistent. Tell the user that and move on. A short "the brief is clear, no grill needed because X" is a valid output.

## The grill loop

Ask **one question at a time**. Wait for the answer before asking the next.

Each question follows this shape:

```
**Q<n>: <single clear question>**

Why I'm asking: <one line — which goal this serves and what's currently unclear>
My recommended answer: <your best guess, with brief reasoning>
```

The recommended answer matters. It does three things at once:

- Surfaces _your_ current assumption so the user can correct it cheaply.
- Lets the user say "yes, that one" and move on quickly.
- Forces you to actually think about the tradeoff rather than fish for input.

After each answer, **revise your internal model** before composing the next question. Questions later in the sequence depend on earlier answers — do not pre-write a rigid list.

## What to ask about

Lean on these four buckets, in roughly this order. Skip a bucket if the brief already nails it.

### 1. Shared understanding

- "When you say <X>, do you mean <A>, <B>, or something else?"
- "What does 'done' look like for this work — what observable thing changes?"
- "Who or what is the consumer of the output?"

### 2. Assumptions

- "I'm assuming <A>. Is that right?"
- "If I had to pick between <approach 1> and <approach 2> right now, I'd pick <1> because <reason>. Push back?"
- "I'm planning to leave <area> untouched — that fits your scope, right?"

### 3. Terminology

- Pick out any word the user has used more than once that could mean multiple things in the codebase. "session", "job", "user", "request", "service", "config", "agent" are common offenders.
- Resolve them by quoting the user's sentence and asking which referent applies, or by offering the two most likely interpretations.

### 4. Need vs want

- "Is <feature/property> a hard requirement, or a nice-to-have?"
- "If we had to ship in half the time, what would you cut?"
- "What would make you reject the result outright?"

## What good questions look like

Good:

> **Q3: When you say "the worker pulls jobs", do you mean a single long-lived process polling the queue, or a short-lived job per task spawned by a scheduler?**
>
> Why I'm asking: terminology — "worker" reads either way in this repo, and the lifecycle affects the deliverable shape.
> My recommended answer: long-lived poller, since `src/workers/runner.py` already loops on the queue.

Bad:

> **Q3: What language is this project in?**

(answerable by `ls *.toml *.json` — do not ask)

> **Q3: Tell me everything about the auth system.**

(open-ended, batched, no recommended answer — useless)

## Stopping criteria

Stop grilling when **any** of these is true:

- You can restate the plan in your own words and the user agrees with the restatement.
- The remaining unknowns are implementation details a reasonable agent can decide during execution without unsaid constraints leaking in.
- The user signals "enough, let's go" — respect it. Note any unresolved item explicitly so it surfaces in the plan or the issues log.

A typical grill is **3–7 questions**. If you are past 10 and still going, you are either grilling on things you should have explored yourself, or the brief is genuinely too vague and you should say so out loud.

## Output after grilling

When the grill ends, produce a short **Shared Understanding** summary:

```
## Shared understanding

- **Goal**: <one sentence>
- **In scope**: <bulleted, concrete>
- **Out of scope**: <bulleted, concrete>
- **Key terms**: <term> = <definition>
- **Assumptions confirmed**: <bulleted>
- **Open questions deferred**: <bulleted, with a note on why deferring is safe>
```

This summary is the deliverable of the grill. Whatever skill or workflow called you (e.g. `bigplan`) feeds this into its next step.

## Example trigger phrases

- "Grill me on this."
- "Stress-test this plan before I commit to it."
- "Interview me — I haven't thought this through."
- "Challenge my assumptions here."
- "Before we write code, poke holes in the plan."
