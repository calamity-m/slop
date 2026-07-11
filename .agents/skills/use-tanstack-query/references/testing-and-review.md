# Testing, Debugging, And Review

## Contents

- Test harness
- What to test
- Debugging sequence
- Common failure patterns
- Final review checklist

## Test Harness

Create a fresh client for every test so cache, retries, and mutation state cannot leak:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import type { PropsWithChildren } from 'react'

export function createQueryTestWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: Infinity },
      mutations: { retry: false },
    },
  })

  function Wrapper({ children }: PropsWithChildren) {
    return (
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    )
  }

  return { queryClient, Wrapper }
}
```

Use the repository's test renderer and request mock layer, commonly Testing Library plus MSW. Mock the network boundary rather than `useQuery`; exercising the real client catches key, lifecycle, retry, cancellation, and invalidation bugs. If the runner warns about open timers, use its recommended `gcTime`/cleanup setup and clear the client after each test.

For hook tests, render under the wrapper and wait for observable state:

```ts
const { result } = renderHook(() => useProject('p1'), { wrapper: Wrapper })
await waitFor(() => expect(result.current.isSuccess).toBe(true))
expect(result.current.data?.id).toBe('p1')
```

Do not assert immediately after scheduling asynchronous cache notifications. Avoid tests that depend on default retries, focus state, connectivity, or cache timing unless those behaviors are the subject of the test.

## What To Test

For queries, cover:

- correct request serialization and response validation;
- initial pending, success, empty, and blocking error states;
- background refetch while cached data remains visible;
- parameter/key changes, including tenant and filter boundaries;
- dependent query gating and absence of avoidable waterfalls;
- cancellation when inputs change or the consumer unmounts, where meaningful;
- pagination placeholder behavior and infinite-page termination;
- SSR hydration without an immediate duplicate request when configured to avoid one.

For SSE-backed queries, also cover:

- one initial snapshot followed by validated create/update/delete events;
- duplicate and out-of-order event IDs or entity versions;
- a disconnect, reconnect, replay, and unrecoverable-gap invalidation;
- events racing the initial snapshot and mutation responses;
- malformed or unauthorized events without cache corruption;
- cleanup on key change and unmount, including React Strict Mode setup/cleanup; and
- bounded work under bursts rather than one refetch per event.

For mutations, cover:

- pending UI and duplicate-submit protection when required;
- success invalidation or authoritative cache replacement;
- server validation errors without corrupting cached data;
- optimistic rollback;
- concurrent writes and out-of-order completion;
- create/delete effects on filtered lists, totals, and page boundaries;
- logout/tenant switching and sensitive cache clearing.

Assert user-visible behavior first, then inspect `queryClient.getQueryData` when the cache contract itself is under test. Use stable keys from the production key factory.

## Debugging Sequence

Diagnose in this order:

1. Confirm package/adaptor major version and inspect app-level QueryClient defaults.
2. Inspect the exact query key and every value captured by `queryFn`.
3. Check whether there are multiple QueryClients or a client recreated during render.
4. Distinguish `status` from `fetchStatus`; determine whether data is absent, stale, fetching, paused, or failed during background refresh.
5. Inspect why a fetch was triggered: mount, key change, invalidation, focus, reconnect, interval, manual refetch, or hydration mismatch.
6. Confirm the query function throws on errors and consumes the signal.
7. Inspect active observers and cached values with installed devtools or `queryClient.getQueryState`.
8. Trace the mutation reconciliation path: exact keys, awaited invalidations, direct writes, optimistic snapshots, and concurrent operations.
9. Reproduce with deterministic network mocks and a fresh client.
10. For pushed data, inspect stream ownership, active connection count, last applied event/version, reconnect behavior, and whether an HTTP response overwrote a newer event.

Strict Mode or remounting often reveals an impure query function, zero freshness, an unstable key, or a client lifecycle bug. Do not “fix” duplicate reads by moving them into an effect or globally disabling useful refetch behavior before finding the trigger.

## Common Failure Patterns

### Stale data after changing filters

The query function reads filters that are absent from the key, or the component imperatively calls `refetch` with state outside the cache contract. Put filters in a serializable key and let the key change drive the query.

### Endless refetching

Look for a QueryClient created during render, unstable key values, render-time invalidation, an effect depending on the query result object, or error handling that remounts the observer. Plain key objects may be recreated safely when structurally equal, but values such as dates/classes/functions are poor key material.

### HTTP 404/500 appears as success

`fetch` resolved normally. Check `response.ok` and throw a normalized error before parsing/returning success data.

### Error UI replaces usable data during refresh

The component treats any `isError` as a blocking first-load failure. Check whether data exists; retain stale content and show an inline refresh error.

### Mutation succeeds but UI stays stale

The mutation neither updates the exact cached shape nor invalidates the relevant prefix, or invalidation targets a key with different types/order. Reuse key factories and await reconciliation where required.

### Optimistic rollback loses a newer edit

Concurrent mutations share a snapshot rollback strategy. Serialize the writes, version operations, patch only owned fields, use optimistic variables, or remove cache-level optimism.

### Memory grows unexpectedly

Inspect high-cardinality keys, long `gcTime`, inactive infinite-query pages, broad prefetching, and persisted caches. Do not solve growth by using the same key for distinct data.

### Hydrated page immediately refetches

The dehydrated data is stale under browser defaults, keys/options differ between server and client, or the browser client is recreated. Share options factories and configure an appropriate SSR freshness window.

## Final Review Checklist

### Ownership And Setup

- Is the data truly asynchronous server state rather than local UI state?
- Is there one stable browser QueryClient, one isolated client per server request, and one fresh client per test?
- Are global defaults intentional and overridden only where the resource differs?

### Keys And Functions

- Does every response-affecting input appear in a serializable array key?
- Do key factories support exact detail, list-prefix, and resource-wide operations?
- Are finite and infinite cache shapes assigned different keys?
- Does each query function throw normalized errors, return defined validated data, and pass through `signal`?
- Are auth and tenant boundaries safe without exposing secrets in keys?

### Lifecycle And UX

- Are `staleTime` and `gcTime` chosen for freshness and retention respectively?
- Does initial pending differ from background fetching and paused connectivity?
- Does useful cached data remain visible during refresh and recoverable errors?
- Are dependent queries genuine dependencies rather than avoidable waterfalls?
- Are pagination and infinite-query transitions guarded against duplicate work and false page claims?

### Mutations

- Is reconciliation explicit and as narrow as correctness allows?
- Are direct cache writes immutable, complete, and shape-correct?
- Are invalidation promises awaited when pending should include refetch?
- Can optimistic changes identify, snapshot, and restore every affected entry?
- Is concurrent mutation ordering safe?

### Verification

- Do tests isolate clients and disable incidental retries?
- Do tests cover error, empty, background refresh, parameter changes, and mutation failure?
- Have installed types, lint, tests, and nearby project conventions been checked?
- If SSR, persistence, or offline mutation replay is used, are serialization, privacy, cache compatibility, and per-request isolation verified?
- If SSE is used, is the finite snapshot separate from the stream, is connection cleanup reliable, and are replay gaps, ordering, authorization, and high event rates handled?
