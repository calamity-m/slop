# Material React Table v3 Reference

## Contents

- Scope and dependencies
- MRT versus raw TanStack Table
- Columns and dynamic schemas
- State and server operations
- TanStack Query v5 pattern
- Loading, errors, and empty data
- MUI configuration and built-in features
- MRT-specific failure modes

## Scope And Dependencies

Material React Table (MRT) v3 is a batteries-included React and Material UI wrapper around TanStack Table v8. Use this reference only when `material-react-table` resolves to major version 3.

Before editing, inspect the installed versions. MRT v3 expects React 18 or newer and Material UI v6-era peers, including MUI icons, MUI X date pickers, and Emotion. Follow the actual lockfile if its compatible minor versions differ. MRT bundles exact versions of `@tanstack/react-table`, React Virtual, match-sorter utilities, and related internals. Do not install or import a second direct `@tanstack/react-table` solely for MRT.

Use named exports:

```tsx
import {
  MaterialReactTable,
  useMaterialReactTable,
  type MRT_ColumnDef,
  type MRT_ColumnFiltersState,
  type MRT_PaginationState,
  type MRT_SortingState,
} from 'material-react-table'
```

Do not use the pre-v2 default import. Render either the hook-created instance:

```tsx
const table = useMaterialReactTable({ columns, data })
return <MaterialReactTable table={table} />
```

or the convenience component for small static tables:

```tsx
return <MaterialReactTable columns={columns} data={data} />
```

Prefer the hook form when external controls, Query, conditional options, table APIs, or custom toolbars are involved.

## MRT Versus Raw TanStack Table

The core concepts in [table-v8.md](table-v8.md) still apply: stable data and columns, unique column IDs, primitive accessor values, controlled-state pairing, manual server boundaries, and durable row IDs.

Use MRT's wrapper APIs instead of rebuilding what it already owns:

| Concern | Raw TanStack Table | Material React Table v3 |
| --- | --- | --- |
| Table hook | `useReactTable` | `useMaterialReactTable` |
| Column type | `ColumnDef<T>` | `MRT_ColumnDef<T>` |
| Cell renderer key | `cell` | `Cell` |
| Markup | Header groups, cells, `flexRender` | `<MaterialReactTable table={table} />` |
| Core row model | Supply `getCoreRowModel()` | MRT configures it internally |
| Loading UI | Application-owned | MRT state flags plus MUI customization props |
| Styling | Application markup/styles | MUI theme and `mui*Props` callbacks |

Do not paste raw-table rendering loops or `getCoreRowModel` into routine MRT configuration. Drop to MRT's headless/subcomponent APIs only when the design genuinely cannot be expressed with its options and render slots.

## Columns And Dynamic Schemas

Static columns use `MRT_ColumnDef<T>[]`. Accessors must return primitive values used for processing; JSX belongs in `Cell`:

```tsx
const columns = useMemo<MRT_ColumnDef<User>[]>(
  () => [
    { accessorKey: 'name', header: 'Name' },
    {
      accessorFn: (row) => new Date(row.createdAt),
      id: 'createdAt',
      header: 'Created',
      filterVariant: 'date-range',
      Cell: ({ cell }) => cell.getValue<Date>().toLocaleDateString(),
    },
  ],
  [],
)
```

For server-defined fields, keep explicit IDs and local allowlists. Never accept server-supplied React components, JSX, functions, MUI props, or arbitrary filter function names.

```tsx
type DynamicRow = { id: string } & Record<string, unknown>
type FieldKind = 'text' | 'number' | 'date' | 'boolean'
type RendererId = 'plain' | 'currency' | 'date' | 'boolean'

type FieldSchema = {
  key: string
  label: string
  kind: FieldKind
  renderer?: RendererId
  sortable?: boolean
  filterable?: boolean
}

type TableSchema = { version: string; fields: FieldSchema[] }

const filterVariants: Record<
  FieldKind,
  MRT_ColumnDef<DynamicRow>['filterVariant']
> = {
  text: 'text',
  number: 'range',
  date: 'date-range',
  boolean: 'checkbox',
}

const renderers: Record<
  RendererId,
  NonNullable<MRT_ColumnDef<DynamicRow>['Cell']>
> = {
  plain: ({ cell }) => String(cell.getValue() ?? ''),
  currency: ({ cell }) =>
    new Intl.NumberFormat(undefined, { style: 'currency', currency: 'USD' })
      .format(Number(cell.getValue() ?? 0)),
  date: ({ cell }) => {
    const value = cell.getValue<Date | null | undefined>()
    return value == null ? '' : value.toLocaleDateString()
  },
  boolean: ({ cell }) => {
    const value = cell.getValue()
    return value == null ? '' : value === true || value === 'true' ? 'Yes' : 'No'
  },
}

function getMrtAccessorValue(row: DynamicRow, field: FieldSchema): unknown {
  const value = row[field.key]
  if (value == null) return value

  switch (field.kind) {
    case 'number':
      return Number(value)
    case 'date':
      return new Date(String(value))
    case 'boolean':
      return value === true || value === 'true' ? 'true' : 'false'
    default:
      return String(value)
  }
}

function buildMrtColumns(schema: TableSchema): MRT_ColumnDef<DynamicRow>[] {
  return schema.fields.map((field) => ({
    accessorFn: (row) => getMrtAccessorValue(row, field),
    id: field.key,
    header: field.label,
    Cell: renderers[field.renderer ?? 'plain'],
    enableSorting: field.sortable ?? false,
    enableColumnFilter: field.filterable ?? false,
    filterVariant: filterVariants[field.kind],
  }))
}
```

For boolean checkbox filters, confirm the backend's value contract. MRT's built-in checkbox filtering commonly represents filter values as string booleans; serialize the actual controlled filter state instead of assuming a JavaScript boolean.

Validate schema keys, supported renderer/kind combinations, and duplicates before building columns. When schema versions change, remount by version or reconcile controlled sorting, filters, visibility, pinning, and order. MRT also generates built-in display column IDs such as selection/action columns; preserve those when explicitly controlling `columnOrder`.

## State And Server Operations

Use MRT's exported state types and pass every controlled state back through `state`:

```tsx
const [columnFilters, setColumnFilters] = useState<MRT_ColumnFiltersState>([])
const [globalFilter, setGlobalFilter] = useState('')
const [sorting, setSorting] = useState<MRT_SortingState>([])
const [pagination, setPagination] = useState<MRT_PaginationState>({
  pageIndex: 0,
  pageSize: 25,
})
```

For server operations, enable all matching manual flags and provide a backend total:

```tsx
const table = useMaterialReactTable({
  columns,
  data,
  getRowId: (row) => row.id,
  manualFiltering: true,
  manualPagination: true,
  manualSorting: true,
  rowCount,
  onColumnFiltersChange: setColumnFilters,
  onGlobalFilterChange: setGlobalFilter,
  onPaginationChange: setPagination,
  onSortingChange: setSorting,
  state: { columnFilters, globalFilter, pagination, sorting },
})
```

Reset `pageIndex` when sorting or filtering changes. An MRT change callback receives either a value or functional updater, just like React state:

```tsx
const resetPage = () =>
  setPagination((old) => (old.pageIndex === 0 ? old : { ...old, pageIndex: 0 }))

const onSortingChange = (
  updater: MRT_SortingState | ((old: MRT_SortingState) => MRT_SortingState),
) => {
  setSorting((old) => (typeof updater === 'function' ? updater(old) : updater))
  resetPage()
}
```

Apply the same shape to column and global filters. If `enableColumnFilterModes` is enabled, the selected filter operators also affect the server response: control the relevant filter-function state, include it in the Query key, and translate only backend-supported operators.

## TanStack Query v5 Pattern

Read [async-query.md](async-query.md) for query-key factories, schema validation, request serialization, cancellation, and mutation rules. The MRT adapter should consume that data rather than fetch in an effect.

Split schema loading from the table component when a schema change should reset all MRT-owned column state:

```tsx
function ReportGrid({ reportId }: { reportId: string }) {
  const schemaQuery = useQuery(schemaOptions(reportId))

  if (schemaQuery.isPending) return <GridSkeleton />
  if (schemaQuery.isError) return <GridError error={schemaQuery.error} />

  return (
    <LoadedReportGrid
      key={schemaQuery.data.version}
      reportId={reportId}
      schema={schemaQuery.data}
    />
  )
}
```

The loaded component owns request-affecting MRT state:

```tsx
function LoadedReportGrid({
  reportId,
  schema,
}: {
  reportId: string
  schema: TableSchema
}) {
  const [columnFilters, setColumnFilters] = useState<MRT_ColumnFiltersState>([])
  const [globalFilter, setGlobalFilter] = useState('')
  const [sorting, setSorting] = useState<MRT_SortingState>([])
  const [pagination, setPagination] = useState<MRT_PaginationState>({
    pageIndex: 0,
    pageSize: 25,
  })

  const columns = useMemo(() => buildMrtColumns(schema), [schema])
  const request = useMemo(
    () => ({ columnFilters, globalFilter, pagination, sorting }),
    [columnFilters, globalFilter, pagination, sorting],
  )
  const rowsQuery = useQuery({
    queryKey: ['report-grid', reportId, schema.version, 'rows', request],
    queryFn: async ({ signal }): Promise<{ rows: DynamicRow[]; rowCount: number }> => {
      const params = toMrtSearchParams(request)
      const response = await fetch(`/api/reports/${reportId}/rows?${params}`, { signal })
      if (!response.ok) throw new Error(`Rows request failed: ${response.status}`)
      return response.json()
    },
    placeholderData: keepPreviousData,
  })

  const data = rowsQuery.data?.rows ?? EMPTY_ROWS
  const resetPage = () =>
    setPagination((old) => (old.pageIndex === 0 ? old : { ...old, pageIndex: 0 }))

  const table = useMaterialReactTable({
    columns,
    data,
    getRowId: (row) => row.id,
    manualFiltering: true,
    manualPagination: true,
    manualSorting: true,
    rowCount: rowsQuery.data?.rowCount ?? 0,
    onColumnFiltersChange: (updater) => {
      setColumnFilters((old) =>
        typeof updater === 'function' ? updater(old) : updater,
      )
      resetPage()
    },
    onGlobalFilterChange: (updater) => {
      setGlobalFilter((old) =>
        typeof updater === 'function' ? updater(old) : updater,
      )
      resetPage()
    },
    onPaginationChange: setPagination,
    onSortingChange: (updater) => {
      setSorting((old) => (typeof updater === 'function' ? updater(old) : updater))
      resetPage()
    },
    muiToolbarAlertBannerProps: rowsQuery.isError
      ? { color: 'error', children: 'Unable to refresh table data' }
      : undefined,
    state: {
      columnFilters,
      globalFilter,
      isLoading: rowsQuery.isPending,
      pagination,
      showAlertBanner: rowsQuery.isError,
      showProgressBars: rowsQuery.isFetching && !rowsQuery.isPending,
      sorting,
    },
  })

  return <MaterialReactTable table={table} />
}
```

Define `EMPTY_ROWS` once at module scope. Implement `schemaOptions` and `toMrtSearchParams` as typed API-boundary functions; every request-affecting value must be in the key and serializer. Debounce a separate global-filter request value when necessary. Disable or clearly mark actions whose correctness depends on fresh data while `isPlaceholderData` is true.

## Loading, Errors, And Empty Data

MRT provides several loading states:

- `state.isLoading`: initial blocking overlay plus cell skeletons. Use when no usable rows exist.
- `state.showSkeletons`: skeletons without the combined loading shortcut.
- `state.showLoadingOverlay`: blocking overlay; avoid during ordinary refetches because it makes the table non-interactive.
- `state.showProgressBars`: top/bottom progress indicators. Use for sorting, filtering, pagination, and background refreshes with retained rows.
- `state.isSaving`: progress and editing-save indicators for mutations.
- `state.showAlertBanner` plus `muiToolbarAlertBannerProps`: persistent table-level error feedback.

Keep Query's initial error distinct from a refetch error with cached data. MRT renders its built-in empty message when stable `data` is empty; customize localization or empty-state rendering only when product language requires it.

## MUI Configuration And Built-In Features

- Prefer the application MUI theme for global consistency. Use MRT's `mui*Props` for table-specific component props and `sx` overrides.
- Use callback forms such as `muiTableBodyCellProps: ({ cell, row, table }) => ({ ... })` when styling depends on table context.
- Use `renderTopToolbarCustomActions`, `renderBottomToolbarCustomActions`, `renderRowActions`, and `renderDetailPanel` for commands and product content.
- Use `displayColumnDefOptions` to configure MRT-generated display columns such as row actions or selection.
- Enable only needed features. MRT enables many behaviors by default; disable column actions, filters, density/fullscreen toggles, pagination, or toolbars when they do not serve the workflow.
- Use `enableRowVirtualization` or `enableColumnVirtualization` for measured rendering bottlenecks. Virtualization changes interaction and accessibility behavior, so test focus, scroll, sticky content, and dynamic row heights.
- Use a durable `getRowId` before enabling selection, editing, expansion, pinning, or row actions.
- Keep cross-page selection as domain IDs. MRT can materialize selected row objects only for rows present in current `data`.

## MRT-Specific Failure Modes

| Symptom | Cause | Fix |
| --- | --- | --- |
| Default import is undefined | Pre-v2 import copied into v3 | Use named `MaterialReactTable` export |
| Hook/import type mismatch | Direct TanStack Table version conflicts with MRT's bundled version | Remove the unnecessary direct dependency/import and use MRT exports |
| JSX accessor breaks sorting/filtering | UI returned from `accessorFn` | Return a primitive and move JSX to `Cell` |
| Continuous rerenders | `data` transformed inline or empty fallback recreated | Pass Query data directly or memoize the transformation; hoist empty arrays |
| Table becomes unusable on every fetch | `isLoading`/overlay used for refetches | Reserve it for initial loading; use `showProgressBars` for background work |
| Server page count is wrong | MRT derives count from the current page | Provide backend `rowCount` or `pageCount` with `manualPagination` |
| Filter UI sends unsupported semantics | MRT filter mode/variant assumed to match API | Translate controlled filters and modes through an explicit backend contract |
| Dynamic columns lose order or leave stale state | Schema changed without resetting/reconciling state | Key the loaded table by schema version or sanitize column state |
| Built-in selection/action column moves unexpectedly | Controlled order omitted MRT display IDs | Include required `mrt-row-*` IDs or let MRT manage column order |
| Styles fight the app theme | Large scattered `sx` overrides | Put stable design tokens/component defaults in the MUI theme and keep local overrides narrow |
