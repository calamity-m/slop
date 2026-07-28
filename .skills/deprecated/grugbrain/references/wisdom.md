# Grugbrain Wisdom

Source: https://grugbrain.dev/

Full teachings of grug brain developer. Pull from the section that matches the question. Do not invent grug wisdom. Quote grug verbatim where it sharpens the point.

## Table of Contents

1. [Complexity](#complexity)
2. [Saying No](#saying-no)
3. [Saying OK (80/20)](#saying-ok-8020)
4. [Factoring Code](#factoring-code)
5. [Testing](#testing)
6. [Agile](#agile)
7. [Refactoring](#refactoring)
8. [Type Systems](#type-systems)
9. [Expression Complexity](#expression-complexity)
10. [DRY](#dry)
11. [Separation of Concerns](#separation-of-concerns)
12. [Closures](#closures)
13. [Logging](#logging)
14. [Concurrency](#concurrency)
15. [Optimization](#optimization)
16. [APIs](#apis)
17. [Parsing](#parsing)
18. [Visitor Pattern](#visitor-pattern)
19. [Frontend](#frontend)
20. [Fads](#fads)
21. [Fear of Looking Dumb (FOLD)](#fear-of-looking-dumb-fold)
22. [Impostor Syndrome](#impostor-syndrome)
23. [Quotes](#quotes)

---

## Complexity

> "complexity _very_, _very_ bad"

Complexity is the apex predator of developers. Enters through well-meaning, over-engineered solutions. Best defense: learn to say no.

> "given choice between complexity or one on one against t-rex, grug take t-rex"

## Saying No

"No" is magic word against complexity. Hard at first, easier over time. May cost career prestige; worth it. Simplicity beat ladder climbing.

## Saying OK (80/20)

When refusal impossible, do 80/20. Most value, least code. Ugly but keeps complexity demon out.

## Factoring Code

Do not factor too early. Wait for natural cut-points. Good cut-point has narrow interface hiding real complexity behind it. Patience and experience reveal when refactor makes sense. Premature factoring create wrong abstraction; wrong abstraction worse than duplication.

## Testing

Tests save many hours but test shamans mislead. Write tests *after* prototype phase, once domain understood. Integration tests are sweet spot: understandable yet realistic. End-to-end too slow and flaky; unit tests too coupled to implementation. Test along the way. Add regression test when bug appears.

> "you may not like, but this peak grug testing"
> "this ideal set of test to grug"

## Agile

> "not terrible, not good"

No silver bullet despite agile shamans. Prototyping and hiring good developers matter more than process.

## Refactoring

Keep refactor small. Stay "not far from shore". Big refactor fail more than small refactor. Big abstraction frameworks (J2EE, OSGi) often cause damage. Apply Chesterton's Fence: understand *why* before demolish. Working ugly code may encode real constraint.

> "grug do not want do major refactor to make life simple, unless thing breaks all the time. what works, works — grug not want spend all day refactoring"

Refactor trigger is *pain*, not *aesthetics*. Code break often, hard to change, bug keep coming back — refactor. Code ugly but quiet — leave alone. Day spent refactoring working code is day not spent shipping.

## Type Systems

90% of value comes from autocomplete and IDE magic (hit dot, see options). Type correctness less important than developer thinks. Big-brain generics seduce toward unnecessary abstraction. Use generics mainly for containers. Trying to encode whole program in type system is complexity demon disguise.

## Expression Complexity

Prefer clear, multi-line expressions over dense one-liners. Name intermediate variables.

> "easier debug! see result of each expression more clearly"

Bad:

```js
return users.filter(u => u.active && u.lastLogin > Date.now() - 86400000 * 30 && !u.banned).map(u => u.email);
```

Good:

```js
const now = Date.now();
const thirtyDaysAgo = now - 86400000 * 30;
const recentlyActive = users.filter(u => u.active && u.lastLogin > thirtyDaysAgo);
const notBanned = recentlyActive.filter(u => !u.banned);
return notBanned.map(u => u.email);
```

## DRY

Respect DRY. But balance. Some repeated code beat overly complex abstraction. Simple obvious duplication often better than elaborate callback / object model. DRY shaman make grug write Factory of Strategies of Visitor; grug not happy.

## Separation of Concerns

Locality of Behavior (LoB) often beat Separation of Concerns (SoC). Put code on the thing that does the thing. Concerns separated across many files waste time understanding interconnection. HTMX and similar approach lean on LoB; grug like.

## Closures

Use closures for abstracting operations over collections. Like salt: small amount go far; too much spoil everything. Callback hell in JavaScript prove the point.

## Logging

Extremely undervalued. Invest heavily.

> "logging _very_ important"

- Log major logical branches (if / for).
- Include request IDs across distributed systems.
- Make log levels dynamically controllable per user if possible.
- Better than debugger in production. Cheap. Fast.

## Concurrency

Fear concurrency. Embrace only when necessary. Lean on simple model: stateless handler, job queue, optimistic concurrency. Thread-local variables useful for framework code. Avoid complex distributed coordination. Distributed transaction big-brain trap.

## Optimization

> "premature optimization is the root of all evil"

Profile concretely before optimize. Watch network call, not just CPU cycle. Network call usually slow part. Do not blindly optimize nested loop without data. n=10 nested loop fine.

## APIs

Design for simple case first; support complexity second (layer). Put method on the thing itself, not elsewhere. Good API not make developer think hard. Java streams example: developer want `filter()` on list, not abstract machinery. Layered API: easy thing easy, hard thing possible.

## Parsing

Recursive descent parser beautiful and understandable. Parser generators create unreadable nightmare. Parsing not mysterious. Simple approach work.

## Visitor Pattern

Bad.

## Frontend

Splitting frontend from backend create two complexity demon lairs. Modern SPA library introduce unnecessary complexity. Even simple form not need massive JavaScript framework. HTMX and Hyperscript exist to avoid frontend complexity demon. React required for some app but make you "alcolyte of complexity demon".

## Fads

Most revolutionary idea already tried (badly) in computing history. Take new approach with grain of salt. Backend wiser (most bad ideas exhausted). Frontend still recycling failure.

## Fear of Looking Dumb (FOLD)

Senior developer should publicly admit "this too complex for grug". Saying "I don't understand" give permission for junior to admit confusion. FOLD major power source for complexity demon. Senior who say nothing while team build cathedral of complexity is failing senior.

## Impostor Syndrome

Grug himself, despite success, often feel impostor. Normal in programming. If everybody feel impostor, nobody actually is one.

## Quotes

Verbatim grug. Quote when sharpens point.

- "complexity _very_, _very_ bad"
- "given choice between complexity or one on one against t-rex, grug take t-rex"
- "you may not like, but this peak grug testing"
- "is fine! is free country sort of"
- "this ideal set of test to grug"
- "grug brain developer not so smart, but program many long year"
- "logging _very_ important"
- "premature optimization is the root of all evil"

## Reads grug recommend

- "Worse is Better" essays
- *A Philosophy of Software Design* — John Ousterhout
