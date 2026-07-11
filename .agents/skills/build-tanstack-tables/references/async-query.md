# Async Rows, Columns, And TanStack Query v5

## Contents

- Boundary contracts
- Async column metadata
- Query keys and request serialization
- Complete server-driven pattern
- Query lifecycle states
- Mutations and invalidation

## Boundary Contracts

Make remote contracts explicit:

```ts
type DynamicRow = { id: string } & Record<string, unknown>

type FieldSchema = {
  key: string
  label: string
  kind: 'text' | 'number' | 'date' | 'boolean'
  renderer?: 'plain' | 'currency' | 'date' | 'boolean'
  sortable?: boolean
  filterable?: boolean
}

type TableSchema = {
  version: string
  fields: FieldSchema[]
}

type PageResult = {
  rows: DynamicRow[]
  rowCount: number
}
```

Validate server responses at the API boundary with the project's schema library when available. Reject duplicate field keys, unsupported kinds/renderers, missing row IDs, invalid totals, and malformed rows.

## Async Column Metadata

Column definitions are synchronous inputs. Fetch metadata first, then translate it into a stable `ColumnDef[]`. Never evaluate server-provided functions, component names, HTML, or format strings as code.

```tsx
type CellRenderer = NonNullable<ColumnDef<DynamicRow>['cell']>

const renderers: Record<NonNullable<FieldSchema['renderer']>, CellRenderer> = {
  plain: ({ getValue }) => String(getValue() ?? ''),
  currency: ({ getValue }) =>
    new Intl.NumberFormat(undefined, { style: 'currency', currency: 'USD' })
      .format(Number(getValue() ?? 0)),
  date: ({ getValue }) => {
    const value = getValue()
    return value == null ? '' : new Date(String(value)).toLocaleDateString()
  },
  boolean: ({ getValue }) => (getValue() ? 'Yes' : 'No'),
}

function buildColumns(schema: TableSchema): ColumnDef<DynamicRow>[] {
  return schema.fields.map((field) => ({
    id: field.key,
    header: field.label,
    accessorFn: (row) => row[field.key],
    cell: renderers[field.renderer ?? 'plain'],
    enableSorting: field.sortable ?? false,
    enableColumnFilter: field.filterable ?? false,
    meta: { kind: field.kind },
  }))
}

const EMPTY_COLUMNS: ColumnDef<DynamicRow>[] = []

const columns = useMemo(
  () => (schemaQuery.data ? buildColumns(schemaQuery.data) : EMPTY_COLUMNS),
  [schemaQuery.data],
)
```

Explicit `id` plus `accessorFn` safely supports arbitrary keys, including keys containing periods. Keep formatters local and derive locale/currency from trusted application configuration.

When a schema version changes, old column order, visibility, sizing, sorting, and filters can reference removed IDs. Either:

- remount the table with `key={schema.version}` when state continuity is unimportant; or
- reconcile each controlled column state against the new set of field IDs.

Never silently send removed sort/filter fields to the API.

## Query Keys And Request Serialization

Every value used by `queryFn` that changes the response belongs in `queryKey`. Use JSON-serializable values and keep resource identity first:

```ts
type GridRequest = {
  pageIndex: number
  pageSize: number
  sorting: SortingState
  columnFilters: ColumnFiltersState
  search: string
}

const gridKeys = {
  all: ['report-grid'] as const,
  schema: (reportId: string) => [...gridKeys.all, reportId, 'schema'] as const,
  rows: (reportId: string, schemaVersion: string, request: GridRequest) =>
    [...gridKeys.all, reportId, schemaVersion, 'rows', request] as const,
}
```

Serialize Table state through an explicit API adapter. Do not make backend parameter syntax leak through components:

```ts
function toSearchParams(request: GridRequest): URLSearchParams {
  const params = new URLSearchParams({
    offset: String(request.pageIndex * request.pageSize),
    limit: String(request.pageSize),
    search: request.search,
  })

  for (const sort of request.sorting) {
    params.append('sort', `${sort.id}:${sort.desc ? 'desc' : 'asc'}`)
  }
  for (const filter of request.columnFilters) {
    params.append(`filter[${filter.id}]`, JSON.stringify(filter.value))
  }
  return params
}
```

The API must allowlist sort and filter field IDs. Client metadata is not authorization.

## Complete Server-Driven Pattern

This pattern fetches schema first, gates rows on schema availability, retains the prior page during page transitions, and resets pagination when request shape changes.

```tsx
import {
  flexRender,
  getCoreRowModel,
  type ColumnFiltersState,
  type OnChangeFn,
  type PaginationState,
  type SortingState,
  type Updater,
  useReactTable,
} from '@tanstack/react-table'
import { keepPreviousData, queryOptions, useQuery } from '@tanstack/react-query'
import { useMemo, useState } from 'react'

const EMPTY_ROWS: DynamicRow[] = []

function resolveUpdater<T>(updater: Updater<T>, previous: T): T {
  return typeof updater === 'function'
    ? (updater as (old: T) => T)(previous)
    : updater
}

function schemaOptions(reportId: string) {
  return queryOptions({
    queryKey: gridKeys.schema(reportId),
    queryFn: async ({ signal }): Promise<TableSchema> => {
      const response = await fetch(`/api/reports/${reportId}/schema`, { signal })
      if (!response.ok) throw new Error(`Schema request failed: ${response.status}`)
      return response.json()
    },
    staleTime: 5 * 60_000,
  })
}

function rowsOptions(
  reportId: string,
  schemaVersion: string,
  request: GridRequest,
) {
  return queryOptions({
    queryKey: gridKeys.rows(reportId, schemaVersion, request),
    queryFn: async ({ signal }): Promise<PageResult> => {
      const params = toSearchParams(request)
      const response = await fetch(`/api/reports/${reportId}/rows?${params}`, { signal })
      if (!response.ok) throw new Error(`Rows request failed: ${response.status}`)
      return response.json()
    },
    placeholderData: keepPreviousData,
  })
}

export function ReportGrid({ reportId }: { reportId: string }) {
  const [pagination, setPagination] = useState<PaginationState>({
    pageIndex: 0,
    pageSize: 25,
  })
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
  const [search, setSearch] = useState('')

  const schemaQuery = useQuery(schemaOptions(reportId))
  const columns = useMemo(
    () => (schemaQuery.data ? buildColumns(schemaQuery.data) : EMPTY_COLUMNS),
    [schemaQuery.data],
  )

  const request = useMemo<GridRequest>(
    () => ({ ...pagination, sorting, columnFilters, search }),
    [pagination, sorting, columnFilters, search],
  )

  const rowsQuery = useQuery({
    ...rowsOptions(reportId, schemaQuery.data?.version ?? 'pending', request),
    enabled: schemaQuery.isSuccess,
  })

  const resetPage = () =>
    setPagination((old) => (old.pageIndex === 0 ? old : { ...old, pageIndex: 0 }))

  const onSortingChange: OnChangeFn<SortingState> = (updater) => {
    setSorting((old) => resolveUpdater(updater, old))
    resetPage()
  }
  const onColumnFiltersChange: OnChangeFn<ColumnFiltersState> = (updater) => {
    setColumnFilters((old) => resolveUpdater(updater, old))
    resetPage()
  }
  const onGlobalFilterChange: OnChangeFn<string> = (updater) => {
    setSearch((old) => resolveUpdater(updater, old))
    resetPage()
  }

  const data = rowsQuery.data?.rows ?? EMPTY_ROWS
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getRowId: (row) => row.id,
    manualPagination: true,
    manualSorting: true,
    manualFiltering: true,
    rowCount: rowsQuery.data?.rowCount ?? 0,
    state: { pagination, sorting, columnFilters, globalFilter: search },
    onPaginationChange: setPagination,
    onSortingChange,
    onColumnFiltersChange,
    onGlobalFilterChange,
  })

  if (schemaQuery.isPending) return <GridSkeleton />
  if (schemaQuery.isError) return <GridError error={schemaQuery.error} />
  if (rowsQuery.isPending) return <GridSkeleton columns={columns.length} />
  if (rowsQuery.isError && !rowsQuery.data) return <GridError error={rowsQuery.error} />

  return (
    <section aria-busy={rowsQuery.isFetching}>
      {rowsQuery.isError ? <InlineRefreshError error={rowsQuery.error} /> : null}
      <table>
        <thead>
          {table.getHeaderGroups().map((group) => (
            <tr key={group.id}>
              {group.headers.map((header) => (
                <th key={header.id} colSpan={header.colSpan} scope="col">
                  {header.isPlaceholder
                    ? null
                    : flexRender(header.column.columnDef.header, header.getContext())}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <tr key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <td key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {data.length === 0 ? <GridEmpty /> : null}
      <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
        Previous
      </button>
      <button
        onClick={() => table.nextPage()}
        disabled={!table.getCanNextPage() || rowsQuery.isPlaceholderData}
      >
        Next
      </button>
      {rowsQuery.isFetching ? <GridProgress /> : null}
    </section>
  )
}
```

Adapt component names, error normalization, endpoint building, validation, search debouncing, and query defaults to the repository. If schema and rows are independent, start both queries in parallel instead of gating rows. If the schema version is already known from routing or bootstrap data, use it directly in both keys.

## Query Lifecycle States

- `isPending`: no successful data is available yet. Show a full initial skeleton or pending view.
- `isFetching`: a request is in flight, including background refreshes. Preserve usable content and show a subtle progress state.
- `isPlaceholderData`: displayed rows belong to the previous key because `keepPreviousData` is active. Avoid claiming they are the new page and consider disabling forward navigation.
- `isError` with data: a refresh failed but stale data exists. Keep the table and show a recoverable inline error.
- `isError` without data: show a blocking error with retry.

Do not set Table's data to a new empty array while every page fetch runs; that creates flicker and resets the user's spatial context.

## Mutations And Invalidation

After an edit/delete mutation:

- update the exact cached page only when the response contains enough authoritative data;
- otherwise invalidate the row-key prefix for the resource;
- invalidate schema separately only when the mutation changes fields;
- reconcile selection after deletion; and
- handle the last row on the last page by moving back a page when necessary.

Use optimistic updates only when rollback can restore every affected page/count consistently. A row can appear on multiple cached pages under different sorts and filters.
