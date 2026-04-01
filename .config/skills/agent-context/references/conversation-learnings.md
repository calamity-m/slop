# Conversation Learnings

Use this reference when the current thread contains information that may deserve a durable home in repo agent context.

## Keep Only Durable Learnings

Good candidates:

- repeated user corrections about how the repo should be changed
- stable preferences about validation, scope control, or risky operations
- naming or organization rules that apply across tasks
- repo-specific workflow facts surfaced during prior work

Bad candidates:

- one-off requests tied to the current ticket
- temporary workarounds
- speculative claims that were never verified
- generic advice that would apply to any repository

## Verify Before Writing

If a learning is factual, verify it against the repository before adding it.

Examples:

- command preferences should match manifests, scripts, CI, or docs
- module boundaries should match the code layout
- risky operations should match the actual deploy, migration, or release flow

If the learning is a user preference rather than a repo fact, write it only if it is stable enough to help future tasks.

## Choose The Right Home

- Put short operational rules in `AGENTS.md`.
- Put longer architecture or pattern explanations in repo docs and link from `AGENTS.md`.
- Omit anything too transient to deserve durable storage.

## Writing Style

- Keep wording direct and repo-scoped.
- Prefer concrete instructions over abstract principles.
- Avoid restating the entire conversation; store only the distilled rule.
