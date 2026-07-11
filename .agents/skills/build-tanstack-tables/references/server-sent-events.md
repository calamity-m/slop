# Live TanStack Tables With Server-Sent Events

## Contents

- Loading and ownership
- Stream-to-table contract
- Materialization pattern
- Filtering, sorting, and pagination
- Table interaction and editing
- Schema and connection changes
- Performance and tests

## Loading And Ownership

First determine whether SSE is the table's authoritative row source or only synchronizes rows loaded by a finite request.

For a long-lived scan whose SSE endpoint periodically returns rows, the stream owns row truth. Feed validated replacement snapshots or scan batches into one materialized collection and pass that collection to TanStack Table. Do not reduce row-bearing events to invalidations when no separate row endpoint is authoritative.

For snapshot synchronization, a finite TanStack Query request owns the row result and SSE updates or invalidates it. Use that model only when it matches the backend contract.

Own the connection beside the table in a resource hook, route/provider, or shared subscription manager. Never open a stream per row or cell. Keep stream lifecycle state such as connecting, scanning, reconnecting, complete, and failed separate from TanStack Query fetch state and from Table's presentation state.

## Stream-To-Table Contract

The event contract must distinguish:

- **Replacement snapshot:** the payload is the complete current result for the subscription scope. Replace `data` atomically.
- **Scan batch:** the payload contributes rows to one named scan generation. Reset or mark the previous generation stale when a new scan begins, then accumulate only batches for the current generation.
- **Delta:** the payload creates, updates, or deletes particular rows from an already materialized result. Apply only when the server defines membership and ordering semantics precisely.

Include a scan/generation ID, monotonic sequence or cursor, durable row IDs, schema version, and canonical request scope where applicable. Define whether duplicate row IDs replace earlier values, whether batch order is display order, how deletes are represented, and what completion means. Ignore stale generations and duplicate sequences. Recover a gap with replay, a complete replacement snapshot, or a clean generation restart.

Give Table a durable domain identity:

```ts
const table = useReactTable({
  data: scan.rows,
  columns,
  getRowId: (row) => row.id,
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
})
```

Use client row models in this example only because `scan.rows` is the complete client-side result. Preserve a stable `scan.rows` reference between published changes and replace only changed row objects so Table can benefit from structural sharing.

## Materialization Pattern

Centralize replacement, accumulation, and generation checks before data reaches the table:

```ts
type GridScanState = {
  scanId: string | null
  lastSequence: number
  rows: DynamicRow[]
  status: 'connecting' | 'scanning' | 'complete' | 'reconnecting' | 'failed'
  scanned: number
  total?: number
}

function reduceGridScan(
  state: GridScanState,
  event: GridScanEvent,
): GridScanState {
  if (event.type === 'scan.started') {
    if (event.scanId === state.scanId && event.sequence <= state.lastSequence) {
      return state
    }
    return {
      scanId: event.scanId,
      lastSequence: event.sequence,
      rows: [],
      status: 'scanning',
      scanned: 0,
    }
  }

  if (event.scanId !== state.scanId || event.sequence <= state.lastSequence) {
    return state
  }

  switch (event.type) {
    case 'rows.snapshot':
      return { ...state, lastSequence: event.sequence, rows: event.rows }
    case 'rows.batch':
      return {
        ...state,
        lastSequence: event.sequence,
        rows: upsertRowsInContractOrder(state.rows, event.rows),
      }
    case 'scan.progress':
      return {
        ...state,
        lastSequence: event.sequence,
        scanned: event.scanned,
        total: event.total,
      }
    case 'scan.completed':
      return { ...state, lastSequence: event.sequence, status: 'complete' }
    case 'scan.failed':
      return { ...state, lastSequence: event.sequence, status: 'failed' }
  }
}
```

This example clears the old result at `scan.started`. Keeping it visible can provide a calmer rescan experience, but label it as stale and keep it separate from new-generation batches until a replacement rule is defined. Do not mix generations into one array.

An external store is usually the clearest owner when SSE is the only row transport. A Query cache may hold the same materialized `GridScanState` when shared Query-keyed access is useful, but the stream remains the producer and Query status does not represent scanning. Query remains a natural fit for finite schema, configuration, scan-start/cancel, row-detail, and mutation requests.

## Filtering, Sorting, And Pagination

Choose one processing boundary for the whole streamed result:

- If the stream eventually materializes all relevant rows, use Table's client filtering, sorting, grouping, and pagination. A long-running partial scan should be labeled partial; visible client sorting is correct for rows received so far but is not a claim about unseen rows.
- If the stream is scoped by server filters, sorting, or pagination, include the canonical request in the subscription identity, close the old stream when it changes, and enable the matching `manualFiltering`, `manualSorting`, and `manualPagination` options together.

For a server-scoped page or view, each replacement snapshot replaces that exact result. A batch can be accumulated only if the server guarantees its membership, order, totals, and completion semantics for that same scope. Supply `rowCount` or `pageCount` from authoritative stream metadata; do not infer final totals from the number of rows received unless the protocol says they are equal.

Do not append a delta to whichever page happens to be visible. A create, update, or delete can change filter membership, rank, page boundaries, totals, aggregates, or permissions. With snapshot-synchronization SSE, invalidate the finite row query when those invariants cannot be projected. With authoritative SSE, wait for a replacement snapshot, use a server-defined delta projection, or restart the affected stream scope; invalidating a nonexistent row query is not recovery.

## Table Interaction And Editing

Stable `getRowId` values preserve selection, expansion, focus targets, and memoized row identity across snapshots. Reconcile controlled state when a completed authoritative result no longer contains a row:

- remove absent IDs from selection and expansion when absence is final rather than merely not-yet-scanned;
- move from an empty last page only after totals or completion establish that it is truly out of range;
- restore focus to a stable nearby control or row; and
- announce meaningful completion or removal without announcing every batch.

Do not replace usable rows with a blocking loading screen during a reconnect. Show a restrained stream status and distinguish stale previous-generation rows from current partial results. Use `aria-busy` for meaningful table-region work, but avoid toggling it or a live region for every raw event.

Define what happens when streamed data touches a row with an unsaved edit:

- **Defer:** keep the draft and flag the newer streamed version.
- **Merge:** merge only fields the draft does not own.
- **Conflict:** preserve the draft and require review.
- **Replace:** use only for non-editable or explicit server-wins fields.

Never copy the entire live result into editable component state on each event. Create a deliberate draft with dirty fields and a base version. Define whether an authoritative replacement snapshot wins over mutation responses and deduplicate mutation echoes with versions or operation IDs.

## Schema And Connection Changes

Scope the stream to tenant, resource, scan parameters, authorization, and schema version. Presentation-only state such as column visibility usually does not reconnect it. Server-owned filter, sort, search, and page inputs do reconnect a view-scoped stream.

Close the old connection before subscribing to a new scope and guard callbacks so late events cannot write into the current generation. Do not apply rows encoded for an unknown schema version. Load finite schema metadata separately when appropriate, or handle an authoritative schema event before accepting its rows.

## Performance And Tests

At high row rates, coalesce incoming batches and publish materialized state on a bounded interval or animation frame. Deduplicate by durable row ID, keep unchanged row objects stable, and bound every buffer. Use pagination or virtualization for large DOM row counts. Virtualization does not bound the memory of a full accumulated scan.

Test with a controllable fake stream. Cover:

- loading before the first row, partial progress, successful empty completion, and failure;
- replacement snapshots and current-generation batch accumulation;
- a new scan resetting or explicitly retaining the previous generation;
- duplicate, stale, skipped, and out-of-order events;
- stable selection and expansion across row replacement;
- absence during a partial scan versus confirmed absence at completion;
- client operations over partial/all rows and server-scoped request changes;
- reconnect by replay, replacement snapshot, and generation restart;
- editing conflicts and mutation-event echoes; and
- burst handling without one render per row or an unbounded queue.

Assert visible headers, rows, progress, completion, pagination, selection, focus, editing state, and connection feedback. Also assert subscription scope, connection count, generation ID, cache/store shape, and cleanup when those contracts are under test.
