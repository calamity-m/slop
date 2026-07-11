# Advanced TanStack Query v5 Patterns

## Contents

- Paginated queries
- Infinite queries
- Prefetching and router integration
- Cancellation
- SSR, hydration, and streaming
- Persistence and offline behavior
- Polling and push updates

## Paginated Queries

Put pagination and all server-owned transforms in the key. Preserve the previous page during transitions when that improves continuity:

```tsx
import { keepPreviousData, queryOptions, useQuery } from '@tanstack/react-query'

function projectsPageOptions(request: ProjectPageRequest) {
  return queryOptions({
    queryKey: projectKeys.list(request),
    queryFn: ({ signal }) => api.getProjects(request, signal),
    placeholderData: keepPreviousData,
  })
}

const pageQuery = useQuery(projectsPageOptions(request))
```

`placeholderData` makes the observer successful with temporary display data; placeholder data is not persisted as real cache data for the new key. Use `isPlaceholderData` to avoid claiming that old rows belong to the new page and to disable next-page actions when the old result cannot prove another page exists.

Reset page index when filters, sort, or page size change unless the server contract intentionally preserves it. Prefetch the next page only when response metadata says it exists.

## Infinite Queries

Use infinite queries for cursor/load-more or unbounded scrolling, not ordinary numbered pagination that needs direct page navigation.

```tsx
const feedQuery = useInfiniteQuery({
  queryKey: ['activity', 'feed', { tenantId, filters }],
  initialPageParam: null as string | null,
  queryFn: ({ pageParam, signal }) =>
    api.getActivity({ cursor: pageParam, filters, signal }),
  getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  getPreviousPageParam: (firstPage) => firstPage.previousCursor ?? undefined,
  maxPages: 10,
})
```

The cached shape is `{ pages, pageParams }`. Preserve both arrays when using `setQueryData`. Return `undefined`/`null` from page-param functions to indicate no page. Guard `fetchNextPage` with `hasNextPage && !isFetchingNextPage` when event sources can fire repeatedly.

Use `maxPages` to bound memory only when both next/previous page parameter functions support the intended navigation. Refetching an infinite query can refetch pages sequentially to avoid stale cursors; large retained histories increase cost. Never use the same key for finite and infinite data.

## Prefetching And Router Integration

Prefetch at a boundary that knows likely navigation: route loaders, hover/focus intent, viewport visibility, or a parent that already has IDs.

```ts
await queryClient.prefetchQuery(projectOptions(projectId))
```

`prefetchQuery` warms the cache and does not return data. Use `fetchQuery` when the caller needs data and a fetch according to freshness rules, or `ensureQueryData` when cached data may satisfy the caller. Check installed types for exact options such as revalidation behavior.

Use the same `queryOptions` factory in loader and component so keys, functions, and freshness cannot drift. Avoid broad speculative prefetching on slow connections or large resources. Prefetched entries without observers are subject to `gcTime`.

## Cancellation

Consume the `AbortSignal` supplied to each query function:

```ts
queryFn: async ({ signal }) => {
  const response = await fetch(url, { signal })
  if (!response.ok) throw new Error(`Request failed: ${response.status}`)
  return response.json()
}
```

Pass the same signal through every nested request when the whole operation should cancel together. For clients without native signal support, use their documented cancellation adapter if installed.

An unused query is not necessarily aborted unless the query function consumes the signal. Consuming it lets Query cancel work when the query becomes obsolete and restore prior cache state according to v5 cancellation semantics. Call `cancelQueries` before an optimistic write so an older response cannot overwrite the speculative value.

Cancellation is cooperative, not transactional. A server may still complete a request after the client stops listening; never use cancellation as rollback for writes.

## SSR, Hydration, And Streaming

Use one `QueryClient` per server request so users never share cache state. In the browser, keep one stable client. A basic flow is:

1. Create a server request client.
2. Prefetch route queries using shared options factories.
3. `dehydrate` the successful cache.
4. Serialize it safely into the response.
5. Render a client `HydrationBoundary` inside the browser provider.

```tsx
// Server boundary
const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 60_000 } },
})
await queryClient.prefetchQuery(projectOptions(projectId))
const state = dehydrate(queryClient)

return (
  <HydrationBoundary state={state}>
    <ProjectScreen projectId={projectId} />
  </HydrationBoundary>
)
```

Hydration state is not automatically a safe serialized string. Use the framework's escaping/serialization facilities to prevent script injection and handle non-JSON values. Successful queries dehydrate by default; errors, pending queries, and mutations need explicit policies where supported. `HydrationBoundary` hydrates queries; use lower-level hydration or persistence APIs for mutation hydration.

Set a nonzero SSR `staleTime` when immediate client refetch would duplicate freshly prefetched work. Avoid rendering the same server data independently both as component props and a Query cache entry unless ownership and update timing are explicit; two representations can drift.

Follow the framework's local Server Components/streaming conventions. Query v5 minor releases vary in pending-query dehydration and streaming helpers, so inspect installed types and existing setup rather than inventing imports.

## Persistence And Offline Behavior

In this skill, “works without internet access” means the documentation is bundled. Building an offline-capable application is a separate product decision.

For persisted caches, use the installed v5 persistence package and a compatible sync/async persister. Configure:

- `maxAge` for persisted data lifetime;
- a `buster` tied to app/schema/cache compatibility;
- serialization for non-JSON data;
- filtering to exclude sensitive or oversized queries;
- `gcTime` at least as long as intended persistence when required by the installed plugin;
- restoration gating so queries do not race cache restore.

Persistence is not durable application storage and does not make stale data correct. Treat storage as attacker-readable unless the platform guarantees otherwise; do not persist secrets or sensitive responses casually.

Network modes have distinct intent:

- `online` (default): pause queries/mutations that need connectivity and resume when online.
- `always`: run regardless of online state, useful for async local storage or transports unrelated to browser connectivity.
- `offlineFirst`: try once, then pause retries, useful when a service worker or HTTP cache may satisfy the request.

For offline mutations, define mutation defaults with stable mutation keys so restored paused mutations still have a mutation function, persist the mutation state, then call `resumePausedMutations` after restoration when the integration requires it. Design idempotency and conflict resolution on the server; replayed writes can be duplicated or obsolete.

## Polling And Push Updates

Use `refetchInterval` for polling only when staleness tolerance and server cost justify it. Pause or vary it based on visibility and query data using APIs supported by installed types. Prevent overlapping ad hoc timers; Query already coordinates observers and requests.

For WebSocket or generic push events that synchronize a finite query:

- update an exact cache entry with a complete versioned event; or
- invalidate affected key prefixes when the event only signals change.

Include entity versions or timestamps to reject out-of-order events. Snapshot-synchronization push still needs an initial query and reconnect recovery. An authoritative row stream can instead materialize its own snapshots or batches, but it still needs explicit ordering, recovery, authorization, and lifecycle rules.

For SSE authority, generation-scoped scans, transport ownership, reconnection, cache materialization, and testing, read [server-sent-events.md](server-sent-events.md).
