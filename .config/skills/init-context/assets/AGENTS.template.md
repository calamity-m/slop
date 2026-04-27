# Init Context

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- Don't silently expand into wiring, integrations, or adjacent work that wasn't requested. If scope is unclear, ask rather than guessing big.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Pre-commit Hooks

**Always prefer pre-commit hooks over repeated and un-verifiable "do X after changes, do Y before commiting"**

Default to adding pre-commit tooling when possible:
- If the user continually asks you to perform an action -> Ask them to setup pre-commit tooling
- If the user mentions you forgot to run tests or some other issue -> Ask them to setup claude, codex or other agent hook tooling


## 6. Project-Specific Notes

**Specifics every person should know when working on this project**

Liimit to 10 lines. Do not include "best coding practices" or "things you should always do after making changes", instead focus instead on critical business rules, or core design decisions.

GOOD:
-> "This project uses new style rust modules, rather than explicit mod.rs use"
-> "Domain-specific language detailed in ..., refer to it when working on query functionality"
-> "Repository serves as a core gateway for the business, uptime is critical"

BAD:
-> "Always remember to run `./gradlew test` after each change
-> "Commit your changes with conventional style commits"
-> "This project is a python repository using FastAPI, It uses the `ruff` linter and `uv` with a virtual environment in .venv"

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
