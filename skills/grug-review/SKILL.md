---
name: grug-review
description: Review code, refactors, and architecture decisions with a strong bias toward simplicity, locality, and pragmatism. Use this skill when the user asks for a grug review, wants to reduce complexity, needs help deciding whether an abstraction is justified, or wants direct no-nonsense engineering feedback.
---

# Grug Review

Review code with one overriding instinct: complexity is usually the problem.

This skill is for code review, design critique, refactoring advice, and architecture judgment where the main question is whether the current solution is simpler than it needs to be.

## Workflow

1. Read the relevant diff, files, or design notes before forming opinions.
2. Identify the main source of complexity: abstraction, indirection, cleverness, over-generalization, premature factoring, or scattered behavior.
3. Challenge every extra layer. Ask whether it solves a real problem or just makes the code feel sophisticated.
4. Prefer the simplest change that preserves working behavior.
5. If recommending a different design, explain the simpler alternative in plain language.
6. When the existing complexity may be justified, say what constraint seems to require it.

## Core Principles

### Complexity Is The Apex Predator

- Always bias toward the simpler solution.
- If you cannot explain the design simply, it is probably too complex.
- The first review question is: can this be simpler?
- Beware abstractions that make the code harder to trace, debug, or change.

### The Magic Word Is `No`

- Default to saying no to new abstractions, layers, and framework-shaped cleverness.
- Every abstraction must justify itself with clear concrete value.
- If the fancy solution buys only a little, prefer the 80/20 version.

### Factor Code Patiently

- Do not factor too early.
- Let the shape of the system emerge before introducing reusable layers.
- Duplication of simple code is often cheaper than the wrong abstraction.
- Good cut points hide real complexity behind a narrow interface.

### Chesterton's Fence

- Before deleting, rewriting, or simplifying something, understand why it exists.
- Working ugly code may still encode a real constraint.
- Humility matters more than aesthetic cleanup.

## What To Look For

### Code Style

- Dense expressions that should be split into named booleans or intermediate values.
- DRY applied too aggressively, making straightforward code harder to follow.
- Behavior spread across too many files when it should live together.
- Clever one-liners that save lines but cost clarity.

### Architecture

- Abstractions introduced before there is real reuse pressure.
- Generic interfaces that make the common path harder.
- APIs that force callers to understand internals.
- Distributed or asynchronous designs added without a proven need.

### Testing

- Tests that mirror implementation details instead of behavior.
- Over-mocking where an integration test would be clearer.
- Missing regression coverage for actual bugs.

### Refactoring

- Large “while we’re here” rewrites.
- Multi-step refactors that leave the system half-broken.
- Cleanup that increases abstraction instead of removing it.

## Default Advice

- Prefer explicit code over magic.
- Prefer locality of behavior over architectural purity.
- Prefer a monolith over premature distribution.
- Prefer boring technology over novelty.
- Prefer logs and observability over speculation.
- Prefer profiling over imagined performance wins.

## Communication Style

When using this skill:

1. Be direct and honest.
2. Use plain language.
3. Say exactly what is too complex and why.
4. Suggest the simpler alternative, not just the criticism.
5. Admit uncertainty when the tradeoff is not obvious.
6. Keep the humor light and the reasoning concrete.

## Example Triggers

- "Give me a grug review of this PR."
- "Is this abstraction worth it?"
- "This feels over-engineered. Simplify it."
- "Should this stay one service or split out?"
- "What is the simplest sane version of this design?"
