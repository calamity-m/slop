# Python Language Lens

Review Python code for typing correctness, mutability hazards, exception hygiene, performance gotchas, and import-time side effects.

## Type Annotations

Typing is non-negotiable. Push hard for it everywhere. Untyped Python is harder to review, harder to refactor, and harder to trust. The bar is full annotation — not "mostly typed."

- Flag every function or method missing parameter or return type annotations, including private helpers. The exception is `__init__` return (always `None`, implicit) and trivially obvious one-liners where the type is genuinely self-evident and annotation adds no information.
- Flag missing `X | None` (or `Optional[X]`) on any parameter or return that can be `None`. A missing `None` in the type is a lie the type checker can't catch.
- Flag `Any` anywhere it appears without a comment explaining why the type is genuinely unknowable. `Any` silences the type checker — it is not a valid substitute for figuring out the actual type.
- Flag untyped class attributes. Every attribute assigned in `__init__` or at class level should have a type annotation.
- Flag `dict`, `list`, `tuple`, `set` without type parameters — `dict[str, int]` not `dict`, `list[str]` not `list`.
- Flag `cast()` calls that paper over a type error rather than fixing the underlying issue.
- Flag missing `TypedDict`, `dataclass`, or `@dataclass` on plain dicts or tuples used as structured data. If it has named fields, it should have a named type.
- If the codebase has no `mypy` or `pyright` configuration, call that out as a gap — annotations without a checker are aspirational, not enforced.

## Mutability Hazards

- Mutable default arguments are a classic bug. Flag `def foo(x=[])`, `def foo(x={})`, `def foo(x=SomeMutableObject())`.
- Shared mutable state in class variables (not instance variables) is often unintentional. Flag `class Foo: items = []` when it should be `self.items = []` in `__init__`.
- Flag in-place mutations on arguments when the caller likely does not expect the argument to change.

## Exception Handling

- Bare `except:` catches `KeyboardInterrupt`, `SystemExit`, and `GeneratorExit` — almost always wrong. Flag it.
- `except Exception:` that swallows the error with no logging or re-raise is a silent failure. Flag it.
- Catching `BaseException` should be rare and deliberate; flag without justification.
- Flag exception handlers that do `pass` with no comment explaining the intentional swallow.

## Performance Gotchas

- `x in some_list` in a loop is O(n) per check. Flag when the list is large or the check is frequent; suggest a `set`.
- `str += other_str` in a loop creates a new string each iteration. Flag in loops; suggest `"".join(parts)`.
- Repeated calls to `len()`, `sorted()`, or other O(n) operations inside a loop body when the result does not change.
- Unnecessary copies of large data structures (`.copy()` on a large dict/list when only reads follow).

## Import-time Side Effects

- Module-level code that does I/O, spawns threads, modifies global state, or raises exceptions makes imports fragile and untestable. Flag it.
- Module-level instantiation of expensive objects (DB connections, HTTP clients) should be deferred to first use or explicit initialization.

## Good Findings

- `def process(items=[])` that accumulates state across calls
- A class attribute `config = {}` shared across all instances
- `except Exception: pass` in a retry loop that hides real failures
- `if x in large_list` inside a tight loop where `large_list` never changes
- `def fetch(url, params, headers):` with no annotations on a public API function
- A function returning `dict` where the shape is fixed — should be a `TypedDict` or `dataclass`
- `result: Any = some_call()` when the actual return type is known
- A codebase with annotations but no `mypy`/`pyright` in CI

## Weak Findings to Avoid

- Flagging `Any` in third-party stubs or interop code where types are genuinely unknowable
- Flagging small `.copy()` calls on tiny dicts as a performance issue
- Requiring annotations on `__init__` return type (it is always `None` and the convention is to omit it)
