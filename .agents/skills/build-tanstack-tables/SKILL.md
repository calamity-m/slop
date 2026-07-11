---
name: build-tanstack-tables
description: Build, configure, debug, or review React data grids using TanStack Table v8, Material React Table v3, and TanStack Query v5. Use for static or server-defined columns, asynchronously loaded rows and schemas, client-side or manual server-side pagination/sorting/filtering, controlled table state, Query integration, Server-Sent Events (SSE) and live row updates, Material UI table configuration, loading/error/empty states, row selection, rendering, performance, accessibility, and tests. This skill is self-contained for work without internet access.
---

# Build TanStack Tables

Build React tables against the stable TanStack Table v8 API and TanStack Query v5. Do not browse for documentation while using this skill. Read local package versions, installed type declarations, and the bundled references instead. Never mix the separate TanStack Table beta API (`useTable`, `tableFeatures`, feature factories) into v8 code that uses `useReactTable`.

## Load The Right Reference

- Read [references/table-v8.md](references/table-v8.md) for column definitions, controlled state, client/server configuration, rendering, and row identity.
- Read [references/async-query.md](references/async-query.md) whenever rows or column metadata load asynchronously, or TanStack Query owns the request lifecycle. It contains the complete server-driven pattern.
- Read [references/server-sent-events.md](references/server-sent-events.md) when a table consumes SSE or another live row stream. It covers snapshot-plus-stream loading, server-pagination correctness, row identity, interaction conflicts, and stream testing.
- Read [references/material-react-table-v3.md](references/material-react-table-v3.md) when the project uses `material-react-table` v3. Also read the async/query reference for remote data because the MRT reference builds on those request-boundary rules.
- Read [references/quality.md](references/quality.md) before finalizing a table UI or diagnosing correctness, performance, accessibility, or test failures.

## Workflow

1. Inspect `package.json`, the lockfile, and nearby tables. Confirm `@tanstack/react-table` is v8-compatible and `@tanstack/react-query` is v5-compatible, or confirm `material-react-table` is v3-compatible with its required React and MUI peers. Follow established UI and API-client patterns.
2. Define the row contract, column source, stable row identifier, and server response shape before creating the table. At minimum, a paged response needs `rows` plus `rowCount` or `pageCount`.
3. Choose one data-processing boundary for the whole dataset:
   - Use client row models when all relevant rows are loaded.
   - Use `manualPagination`, `manualSorting`, and `manualFiltering` together when the server owns those operations. Do not sort or filter only the current server page.
4. Keep `data` and `columns` referentially stable. Use module constants for empty fallbacks and `useMemo` for derived column definitions. Never pass inline `data ?? []` if it creates a new fallback each render.
5. Control only state required outside the table. Pair every `onXChange` callback with `state.x`; otherwise that state freezes. Put all request-affecting state in the Query key.
6. Treat remote column metadata as data, never executable code. Translate validated field/type/renderer identifiers through a local allowlist into `ColumnDef` objects.
7. Render with header groups, visible cells, and `flexRender`. Implement pending, refetching, error, empty, and stale/placeholder states deliberately.
8. For live rows, treat SSE as synchronization after a finite snapshot. Preserve stable row identity and update an exact page only when membership, order, and totals remain correct; otherwise invalidate the affected row queries. See [references/server-sent-events.md](references/server-sent-events.md).
9. Verify behavior at page and filter boundaries, not only the happy path. Use the checklist in [references/quality.md](references/quality.md).

## Non-Negotiable Invariants

- Always provide `getCoreRowModel: getCoreRowModel()`.
- Give accessor-function and display columns explicit, stable IDs.
- Give selectable/editable rows a domain ID through `getRowId`; row indexes are not durable identity.
- Reset `pageIndex` when server-side sorting or filtering changes unless the API contract says otherwise.
- Include pagination, sorting, filters, search, tenant/resource identity, and schema version in a query key when they affect the request.
- Pass Query's `signal` to `fetch` or the API client when supported.
- Use `placeholderData: keepPreviousData` for page transitions that should retain old rows; distinguish `isPending`, `isFetching`, and `isPlaceholderData` in the UI.
- Supply `rowCount` or `pageCount` with `manualPagination`; disable next-page actions when placeholder data cannot establish that the next page exists.
- Do not combine controlled and `initialState` values for the same feature.
- Do not add client row models for operations the server owns.
- Do not append every SSE row to the visible page. Server-owned filters, sorting, pagination, and totals still define page membership and order.

## Version Fence

The references target React, TanStack Table v8, Material React Table v3, and TanStack Query v5. MRT v3 wraps and bundles a pinned TanStack Table v8 dependency; do not add a second direct Table dependency merely to configure MRT. If local types disagree, trust the installed types and preserve the architectural invariants above. For a non-React adapter, reuse the data, identity, state, and server-boundary guidance, but inspect that adapter's local API rather than mechanically copying React hooks.
