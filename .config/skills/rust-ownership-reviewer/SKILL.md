---
name: rust-ownership-reviewer
description: Review Rust codebases, diffs, or focused files for ownership, borrowing, cloning, allocation, and performance tradeoffs. Use when the user asks for a Rust ownership review, wants feedback on clone/Arc/Box/reference usage, or wants a performance-aware review of Rust memory and data-structure choices.
---

# Rust Ownership Reviewer

Review Rust code with a bias toward ownership clarity, borrowing correctness, and explicit performance tradeoffs.

## Core Rule

Do not treat every `clone()`, `Arc<_>`, `Box<_>`, borrow, or allocation as equally important.

Always evaluate cost in context.

Examples:
- Cloning a `String` only to build an error while returning early is usually low value to optimize.
- Cloning or heap-wrapping data that is retained in memory, copied in hot loops, or referenced millions of times is high value to review.

The skill should be explicit about that tradeoff whenever it raises a finding.

## Focus Areas

Prioritize review of:
- `clone()`, `.to_string()`, `.to_owned()`, `collect::<Vec<_>>()`, and other allocation-heavy patterns
- `Arc<_>`, `Rc<_>`, `Box<_>`, `Cow<_>`, `Mutex<_>`, `RwLock<_>`, and similar ownership containers
- reference-heavy APIs that may be overly narrow or awkward to compose later
- places where moving, borrowing, or restructuring data could reduce copies or simplify lifetimes
- `Vec<_>` versus fixed arrays/slices only when bounds are actually small and stable
- async/task boundaries where ownership is widened just to satisfy `'static`

## Review Rules

- Findings first. Order by severity and include file/line references.
- For every finding, explain the performance or ergonomics tradeoff in context.
- Distinguish clearly between:
  - correctness / borrow-safety risks
  - measurable or likely performance issues
  - future API ergonomics or maintainability risks
- Do not recommend unsafe code or broad refactors unless there is a concrete payoff.
- Do not nitpick ownership style when the current shape is already simple and cheap.
- Treat `Arc<_>` and `clone()` as acceptable when they are the clearest tool for the job; only call them out when they appear avoidable, contagious, or expensive in context.
- Treat arrays or bounded buffers as worthwhile only when the size is truly fixed or capped by a real invariant.

## Workflow

1. Inspect the requested files or diff first.
2. Search for obvious ownership hotspots such as:
   - `clone(`
   - `Arc<`
   - `Rc<`
   - `Box<`
   - `Cow<`
   - `to_string(`
   - `to_owned(`
   - `collect::<Vec`
   - `iter().cloned()`
   - `into_owned()`
3. Read surrounding functions and type definitions before judging a hotspot.
4. Flag only issues with a concrete reason, such as:
   - repeated cloning in hot paths
   - ownership wrappers leaking across too much of the API
   - boxed or shared indirection with no real need
   - borrowed APIs that make common call sites awkward or force future clones
   - vectors used where a tiny fixed-size structure would be simpler and more explicit
5. For each issue, state whether the payoff is likely high, medium, or low.
6. When possible, propose a smaller ownership shape, not a vague one.

## Output Shape

Use this structure:
- Findings
- Open questions or assumptions
- Optional short summary

Each finding should say:
- what the ownership issue is
- why it matters here
- what the likely payoff is
- what simpler alternative to consider

## Good Review Examples

Good findings:
- cloning a `String` on every log line when a borrowed `&str` would do
- wrapping a single-owner value in `Arc<Mutex<_>>` before any concurrency exists
- returning borrowed data that forces callers to keep a parent guard alive unnecessarily
- collecting into a `Vec` only to iterate once immediately

Weak findings to avoid:
- “could maybe borrow more here” without explaining how
- “use arrays instead of Vec” without a fixed-size invariant
- “avoid Arc” when the value genuinely crosses task boundaries
- calling out a clone in a cold error path as though it were a hot-path regression
