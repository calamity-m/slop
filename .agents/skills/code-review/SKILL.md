---
name: code-review
description: Review code, diffs, and code paths for consistency with repository conventions, correctness, security, API design, and testability. Use when the user asks for a code review, PR review, diff review, convention check, or wants feedback on specific code. Does NOT trigger for architecture or design-only discussions — use grugbrain for those.
---

# Code Review

Review code and code paths with a direct, opinionated eye. Call out what is wrong, why it matters, and what the concrete alternative is. No hedging, no style nitpicking without cause.

## Core Rules

- Findings first. Order by severity: critical → high → low → nit.
- Every finding must state: what the problem is, why it matters in this context, and what to do instead.
- Never flag style choices that carry no correctness, safety, or ergonomic consequence.
- Distinguish clearly between:
  - **consistency** — code that breaks the repository's own established patterns
  - **correctness** — code that is wrong or will break
  - **security** — code that introduces exploitable risk
  - **API/interface** — code that is awkward to use or will force bad call sites
  - **testability** — code that is hard to verify or whose tests are misleading
- Language-specific findings (ownership, goroutine safety, null safety, etc.) are a separate section after the universal review.

## Workflow

1. **Gather context.** Before forming any opinions, launch 3 independent research tasks in parallel. Wait for all to complete before proceeding.
   - **Diff reader**: read the requested files or diff in full.
   - **Sibling finder**: find classes, modules, or files that serve the same role as the code under review. Read 2-3 siblings in full. See `references/sibling-patterns.md` for what to extract.
   - **Control-flow tracer**: follow 2-3 representative call chains from public entry points to their terminal operations. See `references/control-flow.md` for the taxonomy. Report which style the codebase uses.

2. **Detect language** and load the relevant language lens (`languages/<lang>.md`).

3. **Apply universal lenses:**
   - **Consistency**: code must follow the conventions established by its siblings. The sibling code is the standard — not an external style guide. A new pattern is only acceptable if it is clearly better, not just different. Flag deviations in:
     - Structure and composition style (inheritance vs composition, DI approach)
     - Method organization (object methods vs utility classes vs functional chains)
     - Control-flow style (see `references/control-flow.md`)
     - Error handling and propagation
     - Dependency wiring and configuration
     - Naming vocabulary (the concepts, not just the identifiers)
     - Test approach and assertion style
     - Linter/formatter configs, if present
   - **Correctness**: logic bugs, off-by-ones, broken invariants, unconsidered edge cases, error paths that silently succeed or return garbage
   - **Security**: unsanitized input, injection surfaces, auth/authz gaps, secrets or credentials in code, unsafe or unvalidated deserialization
   - **API/Interface design**: confusing public surface, naming that lies about behavior, callers forced to understand internals, missing or misleading return contracts
   - **Testability**: tests coupled to implementation rather than behavior, over-mocking where a real test would be clearer, missing regression coverage for known or obvious failure modes

4. **Apply language-specific lens** for findings that only matter in this language.

5. **Emit output.**

## Output Shape

```
## Consistency
[severity] <what> — <why it matters here> — <what to do instead>

## Correctness
[severity] <what> — <why> — <alternative>

## Security
[severity] <what> — <why> — <alternative>

## API / Interface
[severity] <what> — <why> — <alternative>

## Testability
[severity] <what> — <why> — <alternative>

## Language-specific (<lang>)
[severity] <what> — <why> — <alternative>

## Open questions
```

Omit any section that has no findings. If there are no findings at all, say so plainly.

## Severity Definitions

- **critical** — will break, corrupt data, or introduce an exploitable vulnerability
- **high** — likely to cause bugs, security gaps, or seriously degrade API usability
- **low** — worth fixing but not urgent; localized risk or minor ergonomics
- **nit** — optional; call it out only if it's a clear improvement with no tradeoff

## Good Findings (Universal Lenses)

- **Consistency**: siblings use constructor injection but the new class uses a static factory to grab its own dependencies
- **Consistency**: every other controller in the package returns `ResponseEntity<T>` but this one returns raw objects
- **Consistency**: the repo uses visible control everywhere but this service buries sequencing 4 calls deep
- **Correctness**: a null check on line 42 but the same reference is dereferenced unconditionally on line 38
- **Correctness**: an `if/else` that handles two of three enum variants — the third silently falls through
- **Security**: user-supplied ID is interpolated into a SQL string instead of using a parameterized query
- **Security**: API key read from environment is logged at DEBUG level
- **API/Interface**: method named `getUser` that can also create the user as a side effect
- **API/Interface**: caller must know to call `init()` before `process()` — nothing enforces the ordering
- **Testability**: test mocks the repository, the service, and the mapper — only testing that mocks were called in order
- **Testability**: no test covers the error path even though the happy path has 4 tests

## What Not To Flag

- Style preferences with no functional consequence
- Hypothetical future problems with no present signal
- Recommendations to rewrite working, simple code
- Vague suggestions like "consider refactoring this" without explaining the payoff

## Resources

### references/

- `references/sibling-patterns.md` — what to extract when reading sibling code
- `references/control-flow.md` — control-flow style taxonomy and identification guide

### languages/

- `languages/rust.md` — Rust ownership, borrowing, allocation, and performance tradeoffs
- `languages/go.md` — Go goroutine safety, error handling, interface design
- `languages/python.md` — Python typing, mutability, exception handling, performance gotchas
- `languages/java.md` — Java nullability, generics, concurrency, resource management
