# Mutations And Cache Reconciliation

## Contents

- Mutation boundaries
- Reconciliation decision order
- Invalidation
- Authoritative cache updates
- Optimistic UI
- Optimistic cache updates and rollback
- Concurrency and broad cache shapes
- Authentication and tenant boundaries

## Mutation Boundaries

Use a query for idempotent reads and a mutation for server writes or other side effects. A mutation is not cached by query key and does not automatically know which queries a write changes.

```tsx
const queryClient = useQueryClient()

const renameProject = useMutation({
  mutationKey: ['projects', 'rename'],
  mutationFn: ({ id, name }: { id: string; name: string }) =>
    api.renameProject(id, name),
  onSuccess: async (savedProject) => {
    queryClient.setQueryData(
      projectKeys.detail(savedProject.id),
      savedProject,
    )
    await queryClient.invalidateQueries({ queryKey: projectKeys.lists() })
  },
})
```

Use `mutate` for event handlers. Use `mutateAsync` only when the caller genuinely needs promise composition; handle its rejection to avoid unhandled promises. Per-call callbacks might not run if the observer unmounts, so put cache integrity and essential side effects in the hook-level mutation options. Keep navigation and component-local notifications at the call site when appropriate.

## Reconciliation Decision Order

Choose the least complex correct approach:

1. **Invalidate affected keys** when a refetch is cheap and the server is authoritative.
2. **Write the mutation response** when it contains the complete canonical entity or result needed by an exact cache entry.
3. **Render optimistic variables in the UI** when only the invoking view needs immediate feedback.
4. **Optimistically update the cache with rollback** only when multiple observers need the speculative value and all affected entries are tractable.

Do not start with optimistic cache updates by habit. Sorting, filtering, pagination, permissions, derived totals, and server normalization often make a correct speculative list update much harder than it appears.

## Invalidation

Invalidate by key factories and as narrowly as correctness permits:

```ts
onSuccess: async (_result, variables) => {
  await Promise.all([
    queryClient.invalidateQueries({ queryKey: projectKeys.detail(variables.id) }),
    queryClient.invalidateQueries({ queryKey: projectKeys.lists() }),
  ])
}
```

Return or await invalidation when the mutation should remain pending until active views reconcile. Do not await it when immediate mutation completion is the desired UX and background reconciliation is acceptable.

Use filters deliberately:

- a prefix key matches descendants;
- `exact: true` limits a match to one exact key;
- `refetchType` controls active/inactive refetching where supported;
- a predicate is a last resort for cache contracts that keys cannot express cleanly.

Invalidating every query after every write hides weak key design and creates unnecessary traffic.

## Authoritative Cache Updates

When the server returns a complete canonical entity, write it directly:

```ts
queryClient.setQueryData<Project>(
  projectKeys.detail(saved.id),
  saved,
)
```

Update immutably:

```ts
queryClient.setQueryData<ProjectPage>(projectKeys.list(filters), (old) => {
  if (!old) return old
  return {
    ...old,
    items: old.items.map((item) => (item.id === saved.id ? saved : item)),
  }
})
```

Never mutate `old` or nested cached objects in place. Preserve the full cached shape, including metadata. If the response is partial, merge only when the contract makes omitted fields unambiguously unchanged; otherwise invalidate.

Use `setQueriesData` only when every matched cache shape can accept the updater. Prefixes often match detail and list entries with different shapes.

## Optimistic UI

For a local pending row or label, render mutation variables without touching the cache:

```tsx
const addProject = useMutation({
  mutationKey: ['projects', 'add'],
  mutationFn: api.addProject,
  onSettled: () =>
    queryClient.invalidateQueries({ queryKey: projectKeys.lists() }),
})

return (
  <>
    <ProjectList />
    {addProject.isPending ? (
      <PendingProject name={addProject.variables.name} />
    ) : null}
  </>
)
```

Use `useMutationState` with a `mutationKey` when another component must render pending variables. Remember it returns an array because concurrent mutations may match. Use `submittedAt` or a client-generated ID for stable optimistic identity.

## Optimistic Cache Updates And Rollback

Cancel relevant refetches, snapshot every changed entry, update immutably, restore on error, and reconcile on settle:

```tsx
const updateProject = useMutation({
  mutationFn: api.updateProject,
  onMutate: async (patch: { id: string; name: string }) => {
    const key = projectKeys.detail(patch.id)
    await queryClient.cancelQueries({ queryKey: key })

    const previous = queryClient.getQueryData<Project>(key)
    queryClient.setQueryData<Project>(key, (old) =>
      old ? { ...old, name: patch.name } : old,
    )

    return { key, previous }
  },
  onError: (_error, _patch, context) => {
    if (context?.previous !== undefined) {
      queryClient.setQueryData(context.key, context.previous)
    }
  },
  onSettled: async (_data, _error, patch) => {
    await queryClient.invalidateQueries({ queryKey: projectKeys.detail(patch.id) })
  },
})
```

Capture whether an entry was absent separately if `undefined` is meaningful to rollback logic. If the mutation changes list membership, counts, ordering, or multiple filter variants, either snapshot and restore every affected query or avoid speculative cache updates.

## Concurrency And Broad Cache Shapes

Concurrent optimistic writes can finish out of order. A simple snapshot rollback can erase a newer optimistic change. Before supporting concurrency, decide whether to:

- serialize related mutations with a supported mutation `scope`;
- assign client operation IDs and ignore stale responses;
- patch fields rather than replace entities;
- render concurrent pending variables outside the cache; or
- skip optimism and invalidate after success.

Paginated and infinite data multiplies the risk: an entity may exist in many cached filters and pages. Server sorting can move it, deletes change totals, and creates can affect page boundaries. Invalidate the relevant list prefix unless the implementation can update all these invariants.

## Authentication And Tenant Boundaries

Prevent cache data from crossing security scopes:

- include tenant/account identity in keys when one client can switch scopes;
- clear or remove sensitive queries on logout and identity changes;
- cancel in-flight queries before clearing when stale responses could repopulate data;
- never place access tokens or secrets in query keys;
- let the transport read current credentials through the repository's auth boundary;
- handle 401/403 centrally without causing infinite refetch or refresh loops.

Query caching is not an authorization boundary. The server must enforce access for every request.
