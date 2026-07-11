# TanStack Query v5 Fundamentals

## Contents

- Mental model and ownership
- QueryClient setup
- API boundary and query options
- Query keys as a cache contract
- Freshness and garbage collection
- Lifecycle states
- Dependent and parallel queries
- Derived data and rendering
- Defaults worth knowing

## Mental Model And Ownership

TanStack Query manages server state: data owned elsewhere that is fetched asynchronously, cached by identity, potentially stale, shared by observers, and reconciled after writes. It does not replace all client state.

Use Query for API responses, database-backed records, remote configuration, and asynchronous local stores. Keep modal visibility, selected tabs, unsaved form input, animation state, and other ephemeral UI state in normal client state. Route params and search params usually remain router state and become inputs to a query key.

A query key names cached data. Observers with the same client and key share one cache entry. The key, query function, freshness policy, and reconciliation rules together form the cache contract.

## QueryClient Setup

Create a stable browser client and provide it above all consumers:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useState, type PropsWithChildren } from 'react'

export function QueryProvider({ children }: PropsWithChildren) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 30_000,
            retry: 2,
            refetchOnWindowFocus: true,
          },
          mutations: { retry: 0 },
        },
      }),
  )

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )
}
```

Choose defaults from product behavior; the numbers above are examples, not universal recommendations. A module-level browser singleton is also valid when it cannot leak between SSR requests. Never create a client directly in a component body on every render.

Use `queryClient.setQueryDefaults(resourcePrefix, options)` for coherent resource-specific policies. Register defaults from broad keys to specific keys because matching defaults merge in registration order.

## API Boundary And Query Options

Keep transport, status checks, parsing, and validation outside presentation components:

```ts
export type Project = { id: string; name: string; updatedAt: string }

async function getProject(id: string, signal?: AbortSignal): Promise<Project> {
  const response = await fetch(`/api/projects/${encodeURIComponent(id)}`, { signal })
  if (!response.ok) {
    throw new Error(`Project request failed: ${response.status}`)
  }
  const value: unknown = await response.json()
  return parseProject(value) // Use the repository's schema validator when available.
}
```

`fetch` does not reject for HTTP error statuses, so check `response.ok`. A query function must resolve defined, valid data or throw. Normalize errors at the API boundary when the UI needs status codes or domain error kinds.

Co-locate keys and reusable options:

```ts
import { queryOptions } from '@tanstack/react-query'

export const projectKeys = {
  all: ['projects'] as const,
  lists: () => [...projectKeys.all, 'list'] as const,
  list: (filters: ProjectFilters) => [...projectKeys.lists(), filters] as const,
  details: () => [...projectKeys.all, 'detail'] as const,
  detail: (id: string) => [...projectKeys.details(), id] as const,
}

export function projectOptions(id: string) {
  return queryOptions({
    queryKey: projectKeys.detail(id),
    queryFn: ({ signal }) => getProject(id, signal),
    staleTime: 60_000,
  })
}
```

Reuse the options with `useQuery(projectOptions(id))`, `prefetchQuery`, `ensureQueryData`, and test setup. `queryOptions` is a runtime identity helper with strong TypeScript inference, not a cache entry.

## Query Keys As A Cache Contract

Use top-level arrays containing serializable primitives, arrays, and plain objects:

```ts
['projects', 'detail', projectId]
['projects', 'list', { tenantId, status, page, sort }]
```

Object property order is normalized by key hashing, while array item order is significant. Prefer one object for named filters so additions do not make positional keys unreadable.

Include every value used by `queryFn` that changes the result. Common omissions are tenant, current user, locale, feature/schema version, page size, filters, and sort. Never close over such a value while leaving it out of the key.

Design keys from general to specific so filters work predictably:

```ts
queryClient.invalidateQueries({ queryKey: projectKeys.all })
queryClient.invalidateQueries({ queryKey: projectKeys.lists() })
queryClient.invalidateQueries({
  queryKey: projectKeys.detail(projectId),
  exact: true,
})
```

Do not share a key between `useQuery` and `useInfiniteQuery`: one stores a value, the other stores `{ pages, pageParams }`.

## Freshness And Garbage Collection

`staleTime` answers: “For how long may observers trust this cached data without automatically revalidating it?”

`gcTime` answers: “After the last observer leaves, for how long should this inactive cache entry stay in memory?”

They solve different problems. A query can be fresh but inactive; it can also be stale and actively displayed.

- Use a longer `staleTime` for data that changes rarely or is pushed by another channel.
- Use `Infinity` only when explicit invalidation or versioned keys reliably announce change.
- Use a longer `gcTime` when users commonly navigate away and back and the data is valuable to retain.
- Do not lower `gcTime` to force freshness; garbage collection does not replace invalidation.
- Avoid `staleTime: 'static'` unless automatic refetch must remain disabled even after invalidation and installed types support it.

Invalidation marks matching queries stale and normally refetches active observers. It does not mean “delete immediately.” Use `removeQueries` only when data must be discarded, such as after logout or tenant changes.

## Lifecycle States

TanStack Query exposes two dimensions:

- `status` / `isPending` / `isSuccess` / `isError` describe whether usable data has resolved.
- `fetchStatus` / `isFetching` / `isPaused` describe whether the query function is running, idle, or waiting for connectivity.

Render them deliberately:

```tsx
const projectQuery = useQuery(projectOptions(projectId))

if (projectQuery.data === undefined) {
  if (projectQuery.isError) {
    return <ProjectError error={projectQuery.error} />
  }
  return <ProjectSkeleton />
}

return (
  <section aria-busy={projectQuery.isFetching}>
    {projectQuery.isError ? <RefreshWarning error={projectQuery.error} /> : null}
    <ProjectView project={projectQuery.data} />
    {projectQuery.isFetching ? <BackgroundProgress /> : null}
  </section>
)
```

After narrowing `isPending` and `isError`, TypeScript knows `data` exists. A background refetch can yield `isFetching: true` while successful cached data remains. If a refresh fails, keep usable data visible and show a recoverable warning where the installed result flags permit it.

For a disabled query without cached data, `status` can be pending while `fetchStatus` is idle. Use `isLoading` when the UI specifically means “the first fetch is actually in flight”; in v5 it derives from pending plus fetching.

## Dependent And Parallel Queries

Gate a true dependency declaratively:

```tsx
const userQuery = useQuery(userByEmailOptions(email))
const userId = userQuery.data?.id

const projectsQuery = useQuery({
  ...projectsByUserOptions(userId ?? ''),
  enabled: userId !== undefined,
})
```

Use `skipToken` instead when supported by the installed version and its improved TypeScript narrowing is useful. Disabled queries opt out of normal automatic refetch behavior; do not use `enabled: false` as a permanent imperative mode when the request can be expressed as key-driven state.

Dependencies create request waterfalls. If requests do not depend on each other's data, render sibling `useQuery` calls or use `useQueries` so they start together:

```tsx
const results = useQueries({
  queries: projectIds.map((id) => projectOptions(id)),
})
```

Flatten avoidable waterfalls with route loaders, server aggregation, prefetching, or parallel queries. Use `useQueries({ combine })` only when a combined result materially simplifies consumers; keep the combine function referentially stable when expensive.

## Derived Data And Rendering

Use `select` for observer-specific projections without changing the cache:

```ts
const projectNamesQuery = useQuery({
  ...projectsOptions(filters),
  select: (projects) => projects.map((project) => project.name),
})
```

Keep expensive selectors stable with a module function or `useCallback`. A selector runs when cached data changes or the selector identity changes. Do not throw from `select`; validate or throw inside `queryFn`.

Do not mirror query data into local state with `useEffect`. That creates two sources of truth and can overwrite user edits during refetch. For editable forms, intentionally snapshot data into a draft at a clear boundary, track dirty state, and define how later server updates are handled.

## Defaults Worth Knowing

Unless configured otherwise in the installed v5 version:

- cached query data is stale immediately (`staleTime: 0`);
- stale active queries can refetch on mount, window focus, and reconnect;
- failed client queries retry with backoff (commonly three retries), while server defaults differ;
- inactive queries are garbage-collected after about five minutes;
- unchanged JSON-compatible subtrees are structurally shared to preserve references;
- multiple observers of the same key share cached data and in-flight work.

Inspect app-level defaults before diagnosing “unexpected” requests. Strict Mode, remounts, focus, reconnect, invalidation, zero stale time, and unstable keys can all expose a bad query function or key design. Query functions must be side-effect-safe reads; writes belong in mutations.
