# Go Language Lens

Review Go code for goroutine safety, error handling discipline, interface design, and concurrency correctness.

## Goroutine Lifecycle

- Every goroutine spawned with `go` must have a clear, bounded exit path.
- Flag goroutines that have no shutdown mechanism or context cancellation.
- Flag goroutines that write to channels or shared state that may already be closed or garbage-collected.
- `sync.WaitGroup` misuse: `Add` called after `go` statement, `Done` not deferred, `Wait` racing with `Add`.

## Error Handling

- Errors must be either handled or explicitly propagated — never silently discarded.
- Flag `_ = someFunc()` when the function can return a meaningful error.
- Flag swallowed errors inside goroutines that have no way to surface them.
- Errors should be wrapped with context using `fmt.Errorf("...: %w", err)` at call boundaries where the context would otherwise be lost.
- Flag `if err != nil { return err }` chains that strip all context across multiple layers.

## Interface Design

- Interfaces should be small — 1 to 2 methods is the target; flag interfaces with 5+ methods unless they model a well-known protocol.
- Interfaces should be defined at the consumer (call site), not the producer. A concrete type exported alongside its own interface is usually a smell.
- Flag interface satisfaction that exists only for test mocking with no other consumer.

## Concurrency

- Shared mutable state must be protected. Flag map writes, slice appends, or struct field mutations happening concurrently without a lock or channel.
- Channels should be used with a clear purpose: signaling, fan-out, work queues. Flag channels used as a workaround for missing synchronization.
- `select` with no `default` blocks indefinitely — flag this if it is unintentional.
- `sync.Mutex` and `sync.RWMutex` should not be copied after first use; flag passing by value.

## defer Correctness

- `defer` inside a loop does not run until the enclosing function returns, not each iteration. Flag deferred `Close()` calls inside loops.
- `defer` with a function that takes a named return value can silently modify the return — flag when this is non-obvious.

## Good Findings

- A goroutine launched in a handler with no context and no exit path
- `err` returned from `json.Unmarshal` silently ignored
- An interface with 8 methods defined in the same package as the only implementation
- A map updated from two goroutines with no lock

## Weak Findings to Avoid

- Flagging `interface{}` / `any` without a concrete reason it causes harm here
- Suggesting channels over mutexes as a blanket preference
- Flagging small, single-implementation interfaces defined purely for clarity
