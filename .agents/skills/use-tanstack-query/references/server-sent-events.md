# TanStack Query With Server-Sent Events

## Contents

- Authority model
- Authoritative scan contract
- Connection ownership
- Materialization pattern
- Query integration
- Ordering and reconnect recovery
- Authentication and lifecycle
- Performance and testing

## Authority Model

Decide what SSE means before choosing a cache strategy:

- **Authoritative row stream:** SSE carries the row data consumers should render. A long-lived scan may periodically emit complete replacement snapshots or emit batches that build one generation of results. Materialize those payloads directly; there may be no row query to invalidate.
- **Snapshot synchronization:** a finite HTTP query owns the authoritative snapshot and SSE carries entity changes or “data changed” notifications. Patch the snapshot when exact reconciliation is safe; otherwise invalidate it.

Do not silently turn the first contract into the second. If the backend spends minutes scanning and returns rows through SSE, refetching an unrelated HTTP endpoint on every message discards the stream's value and creates competing sources of truth.

An SSE connection still must not be a never-resolving `queryFn`. Query functions model finite promise lifecycles; stream connection, progress, completion, and reconnect state need a separately owned lifecycle. The materialized result can live in a dedicated external store or, when shared Query-cache access is useful, be written immutably to a well-defined cache entry. Query's `isPending`, `isFetching`, retry, `staleTime`, and `gcTime` do not describe stream state.

## Authoritative Scan Contract

Make replacement versus accumulation unambiguous. A useful generation-scoped contract is:

```ts
type ScanEvent<Row> =
  | {
      id: string
      type: 'scan.started'
      scanId: string
      sequence: number
    }
  | {
      id: string
      type: 'rows.snapshot'
      scanId: string
      sequence: number
      rows: Row[]
    }
  | {
      id: string
      type: 'rows.batch'
      scanId: string
      sequence: number
      rows: Row[]
    }
  | {
      id: string
      type: 'scan.progress'
      scanId: string
      sequence: number
      scanned: number
      total?: number
    }
  | {
      id: string
      type: 'scan.completed'
      scanId: string
      sequence: number
      rowCount: number
    }
  | {
      id: string
      type: 'scan.failed'
      scanId: string
      sequence: number
      error: { code: string; message: string }
    }
```

The protocol must define each payload's semantics:

- `rows.snapshot` replaces all materialized rows for its scope.
- `rows.batch` contributes to the named scan generation. Define whether duplicate row IDs replace earlier values and whether event order defines display order.
- `scan.started` establishes the current generation and declares whether the previous result is cleared immediately or remains visible as explicitly stale data.
- `scan.completed` confirms that the accumulated generation is complete; zero rows is a successful empty result.
- A new `scanId`, reset event, changed subscription scope, or unrecoverable replay gap cannot be merged accidentally with the old generation.

Validate event names, IDs, generation IDs, sequences, tenant/resource scope, row payloads, and progress values before updating state. Use a durable row ID. Prefer monotonic sequence numbers within a generation and define whether stale, duplicate, and skipped sequences are ignored, replayed, or force a generation restart.

## Connection Ownership

Open one stream at the narrowest shared resource boundary that consumes it: a route/provider, resource hook, or reference-counted subscription manager. Never open a connection per row. Scope it to every input that changes the streamed result, such as tenant, resource, scan parameters, filters, sort, or authorization scope.

Keep connection state separate from materialized data:

```ts
type StreamStatus =
  | 'connecting'
  | 'scanning'
  | 'complete'
  | 'reconnecting'
  | 'failed'
```

Close the old stream before subscribing to a new scope, reject late callbacks from disposed connections, and clean up listeners on unmount. React Strict Mode may set up, clean up, and set up again in development; correct cleanup makes that safe.

Native browser `EventSource` uses a long-lived GET, automatically reconnects, and processes SSE `id` and `retry` fields. It cannot set arbitrary request headers. Same-origin cookies are sent normally; cross-origin cookies require an appropriate `withCredentials` and CORS policy. Use a repository-approved fetch-based SSE client when bearer headers, POST bodies, custom retry behavior, or detailed status handling are required, and verify its abort and parsing behavior from installed types.

## Materialization Pattern

Put generation checks and row semantics in one reducer or store rather than scattering them across components:

```ts
type ScanResult<Row> = {
  scanId: string | null
  lastSequence: number
  rows: Row[]
  status: StreamStatus
  scanned: number
  total?: number
  error?: { code: string; message: string }
}

function applyScanEvent<Row extends { id: string }>(
  state: ScanResult<Row>,
  event: ScanEvent<Row>,
): ScanResult<Row> {
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

  if (event.type === 'rows.snapshot') {
    return { ...state, lastSequence: event.sequence, rows: event.rows }
  }

  if (event.type === 'rows.batch') {
    return {
      ...state,
      lastSequence: event.sequence,
      rows: upsertRowsInContractOrder(state.rows, event.rows),
    }
  }

  if (event.type === 'scan.progress') {
    return {
      ...state,
      lastSequence: event.sequence,
      scanned: event.scanned,
      total: event.total,
    }
  }

  if (event.type === 'scan.completed') {
    return { ...state, lastSequence: event.sequence, status: 'complete' }
  }

  return {
    ...state,
    lastSequence: event.sequence,
    status: 'failed',
    error: event.error,
  }
}
```

This example clears rows on `scan.started`; retain the previous generation only when the product explicitly prefers stale rows during a rescan, and label them as stale until the new generation supplies a replacement. `upsertRowsInContractOrder` must be defined from backend semantics rather than guessed client sorting.

## Query Integration

TanStack Query is optional for an authoritative stream's row collection. Prefer a dedicated external store when SSE is the only way rows load and stream status/progress are first-class. This avoids inventing a fake query function or implying that Query retries and freshness control the stream.

Use Query alongside that store for naturally finite work such as:

- loading schema or scan configuration;
- starting, cancelling, or retrying a scan through a finite request;
- loading row details on demand; and
- mutations whose finite responses need normal reconciliation.

Materialize the authoritative result into Query's cache when multiple existing consumers need Query-keyed access or persistence and the application has an explicit observer abstraction for stream-produced entries:

```ts
function publishScanEvent(
  queryClient: QueryClient,
  scope: ScanScope,
  event: ScanEvent<ResultRow>,
) {
  queryClient.setQueryData<ScanResult<ResultRow>>(
    scanKeys.result(scope),
    (old) => applyScanEvent(old ?? emptyScanResult(), event),
  )
}
```

The stream handler is the producer of that entry. Do not attach a never-resolving `queryFn`, refetch on every row batch, or interpret Query status as scan status. Preserve one exact cache shape, update immutably, and include every stream-scope input in the key. If a finite HTTP snapshot also exists, give its cache entry a distinct ownership contract and define explicitly which source can replace which data.

For notification-style SSE, use the conventional Query strategy instead: apply a complete authoritative entity with `setQueryData`, or invalidate the affected finite-query keys when membership, ordering, counts, or omitted fields cannot be projected safely.

## Ordering And Reconnect Recovery

Native `EventSource` sends the last processed event ID on reconnect when the server supports the protocol. The server must retain enough history to replay from it. Event IDs help transport replay, while generation and sequence fields protect the row model.

For an authoritative scan, choose one recovery rule:

- replay every missing event for the same `scanId` and continue accumulation;
- send a fresh `rows.snapshot` that replaces the materialized collection; or
- start a new generation and clear or mark the previous result stale.

Never keep appending after an unknown gap. Never let late events from an obsolete scan overwrite the current generation. If the stream periodically emits complete snapshots, a later valid snapshot can be the recovery boundary without an HTTP refetch.

Coordinate mutations with streamed data. If a user mutates a row while a scan is active, define whether the next authoritative snapshot wins, versions merge fields, or the UI flags a conflict. Use operation IDs or versions when mutation responses can race stream echoes.

## Authentication And Lifecycle

On logout, tenant change, permission change, or relevant token rotation:

- close the old connection before opening the new one;
- prevent disposed callbacks from writing data;
- clear data the new principal must not see; and
- reconnect through the application's normal authentication boundary.

Do not put bearer tokens in query strings. Treat repeated authorization failures as terminal until credentials change rather than creating a tight reconnect loop. Browser online/offline signals are hints, not proof that the stream is healthy.

## Performance And Testing

For high-rate scans, batch state publication on a bounded interval, deduplicate rows by durable ID, and preserve unchanged row objects. Bound all queues. If every event is a full replacement snapshot, avoid also replaying it as individual row updates. Use pagination or virtualization to control rendered DOM size; they do not reduce the memory required to retain a complete client-side scan.

Test the stream adapter independently with synthetic SSE frames, then test visible behavior. Cover:

- first-event loading, successful empty completion, partial progress, and failure;
- replacement snapshots and generation-scoped batch accumulation;
- duplicate, stale, skipped, and out-of-order sequences;
- a new scan starting before the previous scan completes;
- reconnect by replay, replacement snapshot, and clean generation restart;
- scope changes and unmount preventing late writes;
- mutation/stream conflicts when rows are editable;
- one shared connection for multiple consumers; and
- burst handling without unbounded queues or one render per raw row.

Assert rows, progress, completion, errors, and reconnect feedback first. Inspect the external store or Query cache only when its shape is itself under test. Ensure every source, timer, listener, and test QueryClient is disposed.
