# Live TanStack Tables With Server-Sent Events

## Contents

- Loading and ownership
- Page correctness
- Cache update pattern
- Table interaction and editing
- Schema and connection changes
- Performance and tests

## Loading And Ownership

Load the table's authoritative snapshot with a finite TanStack Query request, then use SSE as a separate synchronization channel. Read the Query skill's SSE guidance when available for transport, authentication, event validation, replay, ordering, and lifecycle details.

Keep the stream scoped to the table resource, tenant, and schema version. Table presentation state such as column visibility usually does not affect the stream; server-owned filters, sorting, search, and authorization might. Prefer one resource stream whose events include enough identity/version information to reconcile all active pages. If the server only streams a particular view, include that canonical request scope in the subscription and replace the stream whenever it changes.

Never open a stream per row or cell. Own it beside the rows query, in a route/provider, or in a shared subscription manager. Close it on cleanup and prevent late events from updating a new resource or request key.

## Page Correctness

For a fully loaded client-side dataset, a validated row event can often update the local collection before TanStack Table applies its client row models.

For manual server-side filtering, sorting, and pagination, the server owns which rows belong on each page and in which order. An event for one row can:

- make the row enter or leave the current filters;
- move it before or after the current page under the active sort;
- shift other rows across page boundaries; or
- change `rowCount`, aggregates, facets, or grouping.

Patch an exact cached page only when the event contract proves membership, rank, and totals remain correct. A common safe case is a complete versioned update to a visible row where none of the active filter/sort/group fields or authorization rules changed. Otherwise invalidate the resource's row-query prefix and let the server recompute the page.

Do not blindly append created rows, remove deleted rows while leaving totals unchanged, or apply client sorting to one server page. Preserving stale rows briefly during the refetch is usually more honest than displaying a locally guessed page.

## Cache Update Pattern

Centralize the decision so the same event cannot be projected differently by multiple components:

```ts
type GridRowEvent =
  | {
      type: 'row.updated'
      row: DynamicRow
      version: number
      changedFields: string[]
    }
  | { type: 'row.deleted'; rowId: string; version: number }
  | { type: 'rows.changed' | 'stream.reset' }

function reconcileGridEvent(
  queryClient: QueryClient,
  reportId: string,
  schemaVersion: string,
  request: GridRequest,
  event: GridRowEvent,
) {
  const rowsPrefix = [...gridKeys.all, reportId, schemaVersion, 'rows'] as const
  const exactKey = gridKeys.rows(reportId, schemaVersion, request)

  if (
    event.type === 'row.updated' &&
    canPatchCurrentPage(event, request)
  ) {
    queryClient.setQueryData<PageResult>(exactKey, (old) => {
      if (!old) return old
      const index = old.rows.findIndex((row) => row.id === event.row.id)
      if (index < 0) return old
      if (Number(old.rows[index].version) >= event.version) return old

      const rows = old.rows.slice()
      rows[index] = event.row
      return { ...old, rows }
    })
    return
  }

  void queryClient.invalidateQueries({ queryKey: rowsPrefix })
}
```

Make `canPatchCurrentPage` conservative and test it against every supported filter, sort, group, and permission rule. If duplicating server semantics would be fragile, always invalidate. Reuse the production key factory and preserve the exact `PageResult` or infinite-query shape.

Schema events need their own path. Invalidate the schema key, then remount or reconcile column state using the new version as described in [async-query.md](async-query.md). Do not apply row payloads created for an unknown schema version.

## Table Interaction And Editing

Use `getRowId` with a durable domain ID so live updates retain row selection, expansion, focus targets, and memoized row identity. Reconcile controlled state when an event deletes a row:

- remove the deleted ID from selection and expansion state;
- move to the previous page if a confirmed refetch leaves the current page beyond the last page;
- restore focus to a stable nearby control or row; and
- announce a user-relevant removal without flooding a live region.

Do not replace the whole table with a loading screen during reconnect or background invalidation. Keep the last usable snapshot, set `aria-busy` only for actual Query fetch work, and show stream connectivity with a separate, restrained status such as “Live updates reconnecting.”

Define what happens when an event touches a row with an unsaved edit:

- **Defer:** keep the draft and queue/flag the newer server version.
- **Merge:** merge only fields the local edit does not own.
- **Conflict:** preserve the draft, show that the source changed, and require review.
- **Replace:** use only for non-editable or explicitly last-write-wins fields.

Never copy the entire live query result into editable component state on each event. Snapshot a deliberate draft, track dirty fields and its base version, and include that version in the mutation when the server supports optimistic concurrency. Deduplicate the mutation response and its SSE echo with versions or operation IDs.

Live reordering is disruptive while a user is focused, selecting text, or operating a row menu. Consider marking the result stale and offering “New updates” before applying reorder-heavy invalidations, but do not claim the visible order is current. Product requirements determine whether immediate correctness or interaction stability wins.

## Schema And Connection Changes

When table request state changes, distinguish cache identity from stream identity:

- Pagination alone need not reconnect a resource-wide stream.
- A view-scoped stream must reconnect for filters, sort, search, or page inputs included in its server subscription.
- Tenant, resource, authorization, and incompatible schema changes always require closing the old stream before subscribing to the new scope.

Guard callbacks with the scope they were created for so an old connection cannot write an event into the current key after a rapid navigation. Recover replay gaps by invalidating the schema and/or row prefixes before restoring the “live” indicator.

## Performance And Tests

At high event rates, coalesce events by row ID and highest version, then update the cache once per bounded interval or animation frame where appropriate. Invalidate once per burst when any event affects membership/order/totals. Avoid rebuilding columns or every row object for an update to one row; immutable replacement of the changed row lets structural sharing and memoization help.

Test with a controllable fake stream and a fresh QueryClient. Cover:

- snapshot loading before, during, and after the first event;
- exact visible-row updates with stable selection and expansion;
- create/delete/filter/sort changes that force invalidation;
- totals and last-page behavior after deletion;
- stale, duplicate, and out-of-order versions;
- request, tenant, resource, and schema changes closing the old stream;
- reconnect replay and reset/gap recovery;
- editing conflicts and mutation-event echoes; and
- burst handling without one refetch or render per raw event.

Assert visible headers, rows, pagination, selection, focus, editing state, and connection feedback. Also assert request parameters, cache shape, connection count, and cleanup when those contracts are the behavior under test.
