# TanStack Query With Server-Sent Events

## Contents

- Ownership model
- Transport and event contract
- Snapshot plus stream pattern
- Cache reconciliation
- Ordering and reconnect recovery
- Authentication and lifecycle
- Performance and testing

## Ownership Model

Use TanStack Query to load and cache a finite authoritative snapshot. Use SSE as a separately owned synchronization channel that updates or invalidates that cache.

Do not make `queryFn` open an `EventSource` and return a promise that resolves only when the stream closes. That leaves the query pending indefinitely and misuses retry, cancellation, freshness, and garbage collection. A typical flow is:

1. Fetch a snapshot with a normal query.
2. Open one stream at the narrowest shared resource boundary that needs live updates.
3. Validate each event and reconcile the relevant cache entries.
4. Recover missed events with replay or invalidation/refetch.
5. Close the stream when its resource, tenant, or authorization scope changes and on unmount.

Connection state such as `connecting`, `open`, `reconnecting`, and `closed` is transport/UI state, not snapshot data. Keep it in local state or a shared connection store when multiple consumers need it. Query's `isFetching` does not describe SSE connectivity.

## Transport And Event Contract

Prefer a small discriminated, versioned event envelope:

```ts
type ProjectEvent =
  | { id: string; type: 'project.updated'; project: Project; version: number }
  | { id: string; type: 'project.deleted'; projectId: string; version: number }
  | { id: string; type: 'projects.changed'; reason?: string }
  | { id: string; type: 'stream.reset' }
```

Validate parsed JSON at the transport boundary before touching the cache. Treat event names, IDs, entity IDs, versions, tenant scope, and payloads as untrusted input. A complete entity plus a monotonic version is easier to reconcile safely than an ambiguous partial patch.

Native browser `EventSource` uses a long-lived GET request, automatically reconnects, and processes SSE `id`/`retry` fields. It cannot set arbitrary request headers. Same-origin cookies are sent normally; cross-origin cookie use requires an appropriate `withCredentials` setup plus server CORS policy. When the endpoint requires bearer headers, POST bodies, custom retry policy, or detailed HTTP status handling, use a repository-approved fetch-based SSE client and verify its abort, parsing, credential, and reconnection behavior from installed types.

The server should send a suitable `text/event-stream` response, periodic heartbeats where infrastructure needs them, cache/proxy headers appropriate to the deployment, stable event IDs, and replay support if lossless recovery matters.

## Snapshot Plus Stream Pattern

Keep key factories and snapshot options reusable. Put stream scope inputs in both the snapshot key and stream URL without exposing secrets:

```tsx
function useLiveProjects(tenantId: string) {
  const queryClient = useQueryClient()
  const projectsQuery = useQuery(projectsOptions(tenantId))
  const [streamState, setStreamState] = useState<
    'connecting' | 'open' | 'reconnecting'
  >('connecting')

  useEffect(() => {
    if (!tenantId) return

    let disposed = false
    const source = new EventSource(
      `/api/projects/events?tenantId=${encodeURIComponent(tenantId)}`,
    )

    source.onopen = () => setStreamState('open')
    source.onerror = () => {
      if (!disposed) setStreamState('reconnecting')
      // Native EventSource reconnects automatically; do not create another timer here.
    }

    const onProjectUpdated = (message: MessageEvent<string>) => {
      const event = parseProjectUpdatedEvent(message.data)
      if (!event) return

      queryClient.setQueryData<Project>(
        projectKeys.detail(event.project.id),
        (old) => (!old || event.version > old.version ? event.project : old),
      )
      // List membership and ordering may have changed.
      void queryClient.invalidateQueries({ queryKey: projectKeys.lists() })
    }

    source.addEventListener('project.updated', onProjectUpdated)

    return () => {
      disposed = true
      source.removeEventListener('project.updated', onProjectUpdated)
      source.close()
    }
  }, [queryClient, tenantId])

  return { ...projectsQuery, streamState }
}
```

Adapt this outline to local React lifecycle helpers and validation conventions. `QueryClient` is stable, so including it in dependencies is correct. React Strict Mode may set up, clean up, and set up again in development; reliable cleanup makes that harmless. Do not suppress dependency checks to keep a connection tied to stale resource inputs.

If many components observe the same stream, own one connection in a provider, route boundary, or reference-counted subscription manager. Never open one connection per row. Confirm browser and server connection limits before using multiple named streams.

## Cache Reconciliation

Choose the narrowest strategy that remains correct:

- Use `setQueryData` for an exact detail key when the event contains a complete authoritative entity and version.
- Use `setQueriesData` only when its filter and updater understand every matched cache shape.
- Invalidate a list prefix when an event can change membership, ordering, aggregates, counts, permissions, or fields omitted by the event.
- Remove or set a detail entry deliberately after deletion, and invalidate lists that may contain it.
- Invalidate broadly on `stream.reset`, unknown schema versions, or unrecoverable replay gaps.

Update immutably and return the old object for duplicate or older versions so structural sharing avoids needless renders. Do not write `undefined` as successful data. Do not reuse finite-query update logic for the `{ pages, pageParams }` shape of an infinite query.

Avoid invalidating on every high-rate event. Buffer a short burst, deduplicate by entity/version, apply one immutable cache update, or coalesce the burst into one invalidation. Bound buffers and flush them on cleanup when correctness requires it. Prefer a periodic reconciliation refetch when the stream is advisory or event volume makes exact client projection too costly.

## Ordering And Reconnect Recovery

Initial loading and streaming have a race: an event can arrive before an older snapshot response and then be overwritten. Pick an explicit protocol:

- Return a snapshot cursor/version, then subscribe with `after=<cursor>` and replay later events.
- Establish the subscription first, buffer events, load the snapshot, then apply only buffered events newer than the snapshot cursor.
- Include monotonic entity versions in both snapshots and events and reject older writes in every reconciliation path.

SSE event IDs help reconnect transport but do not by themselves define entity conflict resolution. Design event processing to tolerate duplicates. If global ordering is unavailable, use per-entity versions and invalidate aggregates or lists that cannot be safely projected.

Native `EventSource` sends the last processed event ID when it reconnects according to the SSE protocol. The server must retain enough history to replay from it. If the server reports a reset/gap or cannot replay, invalidate/refetch the affected keys before treating the cache as current. Consider a low-frequency reconciliation query even with replay when correctness is important.

Coordinate push events with mutations. An optimistic or authoritative mutation response can race an SSE echo. Use operation IDs or versions to deduplicate, and never let an older rollback overwrite a newer pushed value.

## Authentication And Lifecycle

Keep stream scope aligned with cache scope. On logout, tenant change, permission change, or token rotation as required by the transport:

- close the old connection before opening the new one;
- ensure late callbacks from the disposed source cannot write to cache;
- clear or invalidate data that the new principal must not see; and
- reconnect through the application's normal authentication refresh boundary.

Do not put bearer tokens in query strings because URLs leak through logs, history, and monitoring. Prefer secure cookies for native `EventSource`, or an approved fetch-based client when headers are required. Treat repeated authorization failures as terminal until credentials change rather than creating a tight reconnect loop.

Browser offline/online signals are hints, not proof that the stream is healthy. Show a non-blocking stale/reconnecting indicator while cached data remains usable, and expose an explicit refresh path when recovery fails.

## Performance And Testing

Test the stream adapter independently with synthetic SSE frames or the repository's network mock layer, then test cache-visible behavior with a fresh `QueryClient`. Cover:

- initial snapshot success/error and stream connection timing;
- create, update, delete, reset, malformed, duplicate, and out-of-order events;
- snapshot/event and mutation/event races;
- reconnect with replay and reconnect with an unrecoverable gap;
- cleanup after key changes, unmount, logout, and Strict Mode remounts;
- one shared connection for multiple observers; and
- burst coalescing without unbounded queues or refetch storms.

Assert rendered data and connection indicators first. Inspect cache entries, event cursors, and connection counts when those contracts are under test. Use a controllable fake stream rather than wall-clock network timing, and ensure every source, timer, and listener is disposed after each test.
