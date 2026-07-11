---
name: use-tanstack-query
description: Build, configure, debug, test, or review asynchronous server-state flows with TanStack Query v5, especially @tanstack/react-query. Use for QueryClient setup, query keys and options, request lifecycles, dependent or parallel queries, pagination and infinite queries, mutations, invalidation, optimistic updates, prefetching, cancellation, SSR and hydration, persistence and offline behavior, Server-Sent Events (SSE) and other push-driven cache updates, cache debugging, or migration away from effect-driven fetching. This skill is self-contained for work without internet access.
---

# Use TanStack Query

Use TanStack Query v5 as a server-state cache and async lifecycle manager. Do not browse for documentation while using this skill. Inspect the repository, installed package versions, local type declarations, and the bundled references instead. The examples use React; preserve the same cache model with other v5 adapters while following their locally installed API.

## Load The Right References

- Read [references/fundamentals.md](references/fundamentals.md) for every task. It defines ownership, QueryClient setup, keys, query functions, defaults, state semantics, and query composition.
- Read [references/mutations-and-cache.md](references/mutations-and-cache.md) when implementing writes, invalidation, direct cache updates, or optimistic behavior.
- Read [references/advanced-patterns.md](references/advanced-patterns.md) for pagination, infinite queries, prefetching, routers, SSR/hydration, persistence, offline behavior, or cancellation.
- Read [references/server-sent-events.md](references/server-sent-events.md) when loading an initial snapshot and keeping it synchronized with SSE, updating or invalidating caches from events, recovering reconnect gaps, or testing stream behavior.
- Read [references/testing-and-review.md](references/testing-and-review.md) before finalizing an implementation, diagnosing a bug, or reviewing Query code.

## Workflow

1. Inspect `package.json`, the lockfile, the application root, API-client conventions, and nearby Query usage. Confirm the installed package is v5-compatible; trust installed types when a minor-version API differs.
2. Identify ownership before writing hooks:
   - Put remote, asynchronously synchronized data in Query.
   - Keep ephemeral UI state, form drafts, and purely local state outside Query.
   - Treat route/search state as an input to query keys, not a second copy of cached server data.
3. Define the server contract and key factory. Put every input that can change returned data in the key, including resource identity, tenant, locale, filters, sort, page, and authorization scope when cache sharing would otherwise be unsafe.
4. Put transport and response validation at an API boundary. Make the query function resolve valid data, throw a normalized error, and consume the supplied `AbortSignal` when supported.
5. Choose freshness deliberately. Set `staleTime` from how long data remains trustworthy; set `gcTime` from how long inactive data is worth retaining. Do not use either value to paper over a bad key or invalidation design.
6. Model reads declaratively with `queryOptions`, `useQuery`, `useQueries`, or `useInfiniteQuery`. Prefer keys and `enabled`/`skipToken` over imperative refetch effects.
7. Model writes with `useMutation`. Choose the least complex correct reconciliation strategy: invalidate, update from an authoritative response, optimistic UI, then full optimistic cache rollback.
8. When the server pushes changes, load a finite HTTP snapshot with Query and manage the SSE connection as a separate lifecycle. Apply validated, versioned events with exact immutable cache updates when safe; otherwise invalidate the affected keys. See [references/server-sent-events.md](references/server-sent-events.md).
9. Render data state separately from transport state. Preserve useful stale data during background refetches and show blocking UI only when no usable data exists. Represent stream connectivity separately from Query's fetch state.
10. Verify cache behavior across navigation, parameter changes, concurrent mutations, stream reconnects and gaps, failures, refocus/reconnect, and unmount/cancellation using [references/testing-and-review.md](references/testing-and-review.md).

## Non-Negotiable Invariants

- Create one stable browser `QueryClient`; never construct it during an ordinary component render. Create isolated clients per server request and per test.
- Use array query keys. Include every value read by the query function that changes its result.
- Never reuse the same key for finite and infinite queries; their cached shapes differ.
- Make query functions throw on transport, protocol, authentication, and validation failures. Never return `undefined` as successful query data.
- Pass Query's `signal` into cancellable I/O.
- Do not copy query data into component state with an effect. Derive display data with `select`, memoization, or plain render logic; initialize an intentional editable draft explicitly.
- Do not treat `isFetching` as “no data.” It also represents background work. Use `isPending`/data presence for the initial blocking state.
- Update cached data immutably and preserve the exact key/data shape.
- Await or return invalidation when mutation pending state must include reconciliation.
- Add optimistic cache updates only when every affected cache entry can be identified and rolled back correctly.
- Do not put credentials, non-serializable objects, unstable class instances, or functions in query keys.
- Do not use a never-resolving SSE subscription as a `queryFn`. Queries load finite snapshots; a separately owned stream synchronizes the cache and must be closed on cleanup.

## Version Fence

Target TanStack Query v5 and object-form APIs. Do not emit v3/v4 callback patterns for queries, `cacheTime`, positional hook arguments, or `Hydrate`. In v5 use `gcTime`, `HydrationBoundary`, object options, and mutation callbacks for write side effects. If the installed v5 types disagree with a bundled example, adapt the syntax to those types while preserving the ownership, key, freshness, cancellation, and reconciliation rules.
