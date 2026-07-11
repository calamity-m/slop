# Table Quality And Debugging

## Contents

- UI state checklist
- Accessibility checklist
- Performance checklist
- Test strategy
- Failure diagnosis

## UI State Checklist

- Initial schema pending: render a stable table-region skeleton.
- Initial rows pending: show headers when schema exists and a body skeleton sized to the page.
- Background fetch: keep usable rows; expose a subtle busy/progress state.
- Placeholder page: do not label old rows as confirmed new results.
- Empty result: distinguish valid zero results from pending and error states.
- Initial error: show retry and meaningful normalized error text.
- Refetch error with cached data: preserve rows and show an inline warning/retry.
- Partial data: define whether malformed cells render a fallback or fail validation.
- Pagination: display one-based page labels while keeping Table's `pageIndex` zero-based.
- Search: debounce only the request value, not the visible input; reset page when the debounced request changes.
- Layout: reserve sensible dimensions so skeletons, empty states, errors, and pagination do not shift controls unpredictably.
- Live updates: keep usable rows during stream reconnects, distinguish stream connectivity from Query fetching, and avoid disruptive announcements or row reordering while a user is editing.

## Accessibility Checklist

- Prefer semantic `<table>`, `<thead>`, `<tbody>`, `<th scope="col">`, and `<td>` for tabular data.
- Put sorting interaction in a `<button>`, not a clickable header cell.
- Set `aria-sort` to `ascending`, `descending`, or `none` on sortable headers.
- Give icon-only controls accessible names and visible hover/focus affordances.
- Preserve keyboard operation for sorting, pagination, menus, resizing, and selection.
- Associate selection checkboxes with rows and provide a mixed state for partial select-all.
- Use `aria-busy` on the stable results region during background work; avoid repeatedly announcing every minor refetch.
- Do not hide a blocking error only in a toast.
- For virtualized grids, preserve correct row/column semantics and counts; test with keyboard and assistive technology.

## Performance Checklist

- Keep `data`, `columns`, query inputs, and shared options stable.
- Avoid inline `[]`, column construction, or expensive accessors in render.
- Format expensive values once at the appropriate layer or use memoized cells after measurement proves it useful.
- Do not control the entire Table state at a high component level unless required; frequently changing sizing state can cause broad rerenders.
- Debounce high-frequency server search/filter requests and let Query cancel obsolete fetches through `signal`.
- Use pagination or virtualization for large DOM row counts. They solve different problems and may be combined.
- Measure before adding `React.memo`; unstable props defeat it.

## Test Strategy

Test pure boundaries without rendering first:

1. `buildColumns` maps every supported field kind, rejects duplicate/unknown schema values at validation, and gives stable IDs.
2. `toSearchParams` preserves multi-sort order, encodes filter values, calculates offset, and handles special characters.
3. Query-key factories change for every request-affecting value and do not change for presentation-only state.
4. State reconciliation removes sorting, filtering, order, and visibility entries for deleted schema fields.

Then test behavior through the UI with the project's normal React test stack:

1. Resolve schema, then rows; assert headers and cells.
2. Change sort; assert `pageIndex` resets and the next request contains the new sort.
3. Change filter/search; assert the same boundary behavior.
4. Change page; assert old rows remain during placeholder data and controls represent the transient state honestly.
5. Reject initial requests and refetches separately; verify blocking versus inline errors.
6. Return zero rows; verify empty state rather than skeleton.
7. Change schema version; verify stale column state is reset or reconciled.
8. Select rows across page changes; verify domain IDs, not indexes.

For SSE-backed tables, additionally test:

1. Apply a versioned update to a visible row without losing selection or expansion keyed by domain ID.
2. Delete a selected row and reconcile selection, row count, empty-page navigation, and focus.
3. Receive a create/update that may change filter membership or sort position; verify exact patching is used only when the page remains provably correct and otherwise verify invalidation.
4. Change table request state; verify the old stream closes and events cannot write into the new key.
5. Disconnect and reconnect with replay, duplicate events, and an unrecoverable gap.
6. Deliver an event while a cell has an unsaved draft; verify the declared merge, conflict, or defer policy.

Prefer observable UI and request assertions over snapshots of internal Table objects. Use fake timers only around debouncing, and restore them after each test.

## Failure Diagnosis

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Infinite rerenders or constant row processing | New `data`/`columns` reference each render | Hoist constants or memoize derivation at the true dependency boundary |
| Sorting/filter UI never changes | `onXChange` supplied without `state.x` | Pass the controlled value back through `state` |
| Only current page sorts or filters | Client row model combined with server pagination | Move all dataset operations to the server and enable matching `manual*` flags |
| Page becomes empty after filtering | Manual pagination does not auto-reset page index | Reset `pageIndex` when request shape changes |
| Selection moves to another record | Default index row IDs | Supply `getRowId` using a durable domain key |
| Nested/dotted dynamic key reads wrong value | Dynamic field used as `accessorKey` | Use explicit `id` and `accessorFn: row => row[key]` |
| Old schema state references missing columns | Schema changed without reconciliation | Remount by schema version or sanitize controlled column state |
| Flicker on every page | Data replaced with empty rows while fetching | Use Query v5 `placeholderData: keepPreviousData` |
| Refetch loop | Request key/object or effect is rebuilt incorrectly | Use declarative Query keys and stable derived request state; remove fetching effects |
| Wrong cached results | A request dependency is absent from query key | Add every response-affecting variable to the key |
| Abort does nothing | Query `signal` not passed to transport | Forward `signal` to `fetch` or supported client |
| Next remains enabled incorrectly | Missing/unknown total or placeholder count | Supply `rowCount`/`pageCount` and gate transient navigation |
| Cell shows `[object Object]` or sorts strangely | Accessor returns non-primitive data | Return a primitive or define matching render/sort/filter functions |
| Refresh error removes usable table | Error branch ignores cached data | Distinguish initial error from refetch error with existing data |
| Live row appears on the wrong page or in the wrong order | SSE event was appended without applying server-owned filter/sort/page rules | Invalidate affected pages or patch only when membership and rank are provably unchanged |
| Selection jumps after a live update | Row indexes or mutable fields are used as identity | Use a durable domain ID with `getRowId` and reconcile deleted IDs |
| Duplicate connections or updates | Stream setup leaked across remounts or each row opened a connection | Own one connection at the resource boundary and close it during every cleanup |
