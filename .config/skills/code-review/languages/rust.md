# Rust Language Lens

Review Rust code with a bias toward ownership clarity, borrowing correctness, and explicit performance tradeoffs.

## Core Rule

Do not treat every `clone()`, `Arc<_>`, `Box<_>`, borrow, or allocation as equally important.

Always evaluate cost in context:
- Cloning a `String` only to build an error while returning early is usually low value to optimize.
- Cloning or heap-wrapping data that is retained in memory, copied in hot loops, or referenced millions of times is high value to review.

State the tradeoff explicitly for every ownership finding.

## Focus Areas

- `clone()`, `.to_string()`, `.to_owned()`, `collect::<Vec<_>>()`, and other allocation-heavy patterns
- `Arc<_>`, `Rc<_>`, `Box<_>`, `Cow<_>`, `Mutex<_>`, `RwLock<_>`, and similar ownership containers
- Reference-heavy APIs that may be overly narrow or awkward to compose
- Places where moving, borrowing, or restructuring data could reduce copies or simplify lifetimes
- `Vec<_>` versus fixed arrays/slices only when bounds are actually small and stable
- Async/task boundaries where ownership is widened just to satisfy `'static`

## Hotspot Patterns

Search for these before judging:
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

Read the surrounding functions and type definitions before flagging a hotspot.

## Review Rules

- For every finding, explain the performance or ergonomics tradeoff in context.
- Distinguish between: correctness/borrow-safety risks, measurable or likely performance issues, and future API ergonomics risks.
- Do not recommend unsafe code or broad refactors unless there is a concrete payoff.
- Do not nitpick ownership style when the current shape is already simple and cheap.
- Treat `Arc<_>` and `clone()` as acceptable when they are the clearest tool for the job; only call them out when they appear avoidable, contagious, or expensive in context.
- Treat arrays or bounded buffers as worthwhile only when the size is truly fixed or capped by a real invariant.
- Rate every finding using the universal severity scale: critical, high, low, or nit.

## Good Findings

- Cloning a `String` on every log line when a borrowed `&str` would do
- Wrapping a single-owner value in `Arc<Mutex<_>>` before any concurrency exists
- Returning borrowed data that forces callers to keep a parent guard alive unnecessarily
- Collecting into a `Vec` only to iterate once immediately

## Weak Findings to Avoid

- "Could maybe borrow more here" without explaining how
- "Use arrays instead of Vec" without a fixed-size invariant
- "Avoid Arc" when the value genuinely crosses task boundaries
- Calling out a clone in a cold error path as though it were a hot-path regression
