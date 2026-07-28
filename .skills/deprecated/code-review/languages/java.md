# Java Language Lens

Review Java code for nullability discipline, generics correctness, concurrency safety, exception handling, and resource management.

## Nullability

- Flag `Optional.get()` without a preceding `isPresent()` or `orElse`/`orElseThrow` — it will throw with no useful context.
- Flag methods that can return `null` but are not annotated `@Nullable` and not documented.
- Flag parameters that are dereferenced without null checks when the caller cannot guarantee non-null.
- Prefer `Objects.requireNonNull()` at method entry for non-null preconditions over silent NPE later.
- Flag `@NonNull` annotations on fields that are assigned in `@PostConstruct` or lazy initializers — the annotation is misleading.

## Generics

- Raw types (`List` instead of `List<?>` or `List<Foo>`) bypass compile-time safety. Flag them.
- `@SuppressWarnings("unchecked")` on unchecked casts should have a comment explaining why the cast is safe. Flag without justification.
- Wildcard overuse: `List<? extends Foo>` when the code only reads, or `List<? super Foo>` when the code only writes — fine; flag mixed use that makes the API confusing.
- Flag generic type parameters with single-letter names on public APIs when a descriptive name would clarify intent.

## Concurrency

- Shared mutable fields accessed from multiple threads must be synchronized, `volatile`, or replaced with a concurrent collection. Flag unprotected access.
- `volatile` is not a replacement for synchronization when a compound check-then-act is involved. Flag `if (volatile_field == null) volatile_field = new Foo()`.
- Lock ordering: acquiring multiple locks in different orders across code paths causes deadlocks. Flag if detectable.
- `synchronized` on a non-final field that can be reassigned gives no protection. Flag it.
- Prefer `java.util.concurrent` primitives (`ReentrantLock`, `AtomicReference`, concurrent collections) over raw `synchronized` blocks for clarity and composability.

## Checked Exceptions

- Swallowing a checked exception in a `catch` block with only `e.printStackTrace()` or an empty body hides failures. Flag it.
- `throws Exception` or `throws Throwable` on a public API is a contract that says nothing. Flag; suggest the specific exception.
- Wrapping a checked exception in `RuntimeException` is sometimes valid; flag when the original exception is not included as a cause.
- Flag checked exceptions caught and re-thrown as a different checked exception that loses type information.

## Resource Management

- Any `Closeable` or `AutoCloseable` (streams, connections, readers, writers) must be closed. Flag manual `try/finally` that can be replaced with `try-with-resources`.
- Flag `close()` called only in the happy path but not in the exception path.
- Flag `Connection`, `Statement`, or `ResultSet` that are created in a method and not closed in the same scope.

## Records for Immutable Data

Java 16+ `record` types are the right default for immutable data carriers, DTOs, value objects, and response/request shapes. Flag classes that should be records when:

- The class holds data, has no meaningful mutable state, and its identity is purely its field values
- The class is a DTO, API response/request body, event payload, or value object with manual `equals`/`hashCode`/`toString`
- The class has only `final` fields, a constructor that sets them, and nothing else
- A class uses the builder pattern solely to work around a telescoping constructor — a compact record constructor handles validation more cleanly

When recommending a record, state what boilerplate it eliminates (`equals`, `hashCode`, `toString`, accessor methods, constructor).

Do not recommend records when:

- The class is a JPA/Hibernate entity — records do not work with proxy-based lazy loading
- The class needs to be mutated after construction
- The class extends another class (records implicitly extend `Record` and cannot extend others)
- The framework requires a no-arg constructor (many serialization libraries now support records, but flag if uncertain)

## Good Findings

- `Optional<Foo> result = ...; return result.get()` with no presence check
- A `List list` field declared without a type parameter across a public API
- A `static boolean initialized` field read and written from multiple threads with no synchronization
- `catch (Exception e) {}` in a scheduler task that silently stops the task on first failure
- A `FileInputStream` opened in a method with `close()` only in the happy-path `finally` block
- A class with only `final` fields, a constructor, and hand-rolled `equals`/`hashCode`/`toString` — should be a `record`
- A DTO with a Lombok `@Value` or `@Builder` and no mutation — `record` is the cleaner built-in alternative

## Weak Findings to Avoid

- Flagging raw types in pre-generics legacy code that is not being changed
- Insisting on `try-with-resources` when the `Closeable` lifetime genuinely spans multiple methods
- Suggesting concurrent primitives in code that is explicitly single-threaded by design
