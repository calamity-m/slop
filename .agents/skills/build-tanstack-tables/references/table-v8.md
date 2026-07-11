# TanStack Table v8 Reference

## Contents

- Mental model
- Column definitions
- Stable inputs and identity
- Controlled state
- Client-side configuration
- Server-side configuration
- Rendering
- Feature configuration

## Mental Model

TanStack Table is headless. `useReactTable` creates state and row-model APIs; application code owns data fetching, markup, controls, styling, and request serialization.

The row-model pipeline is:

```text
core -> filtered -> grouped -> sorted -> expanded -> paginated -> rendered
```

An enabled `manual*` option bypasses that client transformation and uses the corresponding pre-transformation model. Configure every operation consistently across the entire dataset.

## Column Definitions

Use `ColumnDef<TData>` or `createColumnHelper<TData>()` for static typed data:

```tsx
import { createColumnHelper, type ColumnDef } from '@tanstack/react-table'

type User = { id: string; name: string; email: string; createdAt: string }
const column = createColumnHelper<User>()

const columns: ColumnDef<User>[] = [
  column.accessor('name', { header: 'Name' }),
  column.accessor('email', { header: 'Email' }),
  column.accessor((row) => new Date(row.createdAt), {
    id: 'createdAt',
    header: 'Created',
    cell: ({ getValue }) => getValue<Date>().toLocaleDateString(),
    sortingFn: 'datetime',
  }),
  column.display({
    id: 'actions',
    enableSorting: false,
    cell: ({ row }) => <RowActions user={row.original} />,
  }),
]
```

Rules:

- Accessor values feed sorting, filtering, and grouping. Prefer primitives unless a matching custom function exists.
- `accessorKey` derives an ID, but periods imply nested access and are normalized in IDs. For arbitrary server field names, prefer an explicit `id` plus `accessorFn`.
- An `accessorFn`, display column, or JSX header needs an explicit stable `id`.
- Read the original domain object from `row.original`; read the accessor result from `getValue()`.
- Put application-specific column information in `columnDef.meta`, with module augmentation when shared typing is useful.

## Stable Inputs And Identity

Table recomputes when `data` or `columns` changes by reference. Keep both stable:

```tsx
const EMPTY_ROWS: User[] = []
const STATIC_COLUMNS: ColumnDef<User>[] = [/* ... */]

function UsersTable() {
  const query = useUsersQuery()
  const data = query.data?.rows ?? EMPTY_ROWS
  const columns = STATIC_COLUMNS

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getRowId: (row) => row.id,
  })
}
```

Use `useMemo` only when columns depend on component inputs. Do not memoize a value with an unstable dependency merely to claim stability.

Default row IDs are indexes. Index IDs break selection, expansion, and edits after sorting, paging, or refresh. Use a durable domain key:

```tsx
getRowId: (row) => row.id
```

## Controlled State

Control state that affects requests, URLs, persistence, or surrounding UI. Let purely local features remain internal when possible.

```tsx
const [sorting, setSorting] = useState<SortingState>([])
const [pagination, setPagination] = useState<PaginationState>({
  pageIndex: 0,
  pageSize: 25,
})

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  state: { sorting, pagination },
  onSortingChange: setSorting,
  onPaginationChange: setPagination,
})
```

Pair `onSortingChange` with `state.sorting`, and follow the same rule for every controlled feature. An `onXChange` callback without `state.x` freezes that feature. Do not set both `initialState.sorting` and `state.sorting`; the controlled value wins.

Callbacks receive either a value or functional updater. Preserve both forms when adding logic:

```tsx
function resolveUpdater<T>(updater: Updater<T>, previous: T): T {
  return typeof updater === 'function'
    ? (updater as (old: T) => T)(previous)
    : updater
}

const onSortingChange: OnChangeFn<SortingState> = (updater) => {
  setSorting((old) => resolveUpdater(updater, old))
  setPagination((old) => ({ ...old, pageIndex: 0 }))
}
```

## Client-Side Configuration

Use this only when `data` contains the full dataset for every enabled operation:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
  state: { sorting, columnFilters, globalFilter, pagination },
  onSortingChange: setSorting,
  onColumnFiltersChange: setColumnFilters,
  onGlobalFilterChange: setGlobalFilter,
  onPaginationChange: setPagination,
})
```

Do not infer server-side processing merely from dataset size. Consider response size, browser memory, column complexity, and whether the server can return the full set cheaply.

## Server-Side Configuration

Use one consistent server boundary for pagination, sorting, and filtering:

```tsx
const table = useReactTable({
  data: result.rows,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getRowId: (row) => row.id,
  manualPagination: true,
  manualSorting: true,
  manualFiltering: true,
  rowCount: result.rowCount,
  state: { pagination, sorting, columnFilters, globalFilter },
  onPaginationChange: setPagination,
  onSortingChange,
  onColumnFiltersChange,
  onGlobalFilterChange,
})
```

Do not add `getPaginationRowModel`, `getSortedRowModel`, or `getFilteredRowModel` for operations owned by the server. `manualPagination` expects already paginated rows. Supply `rowCount` so Table calculates page count, or supply `pageCount` when that is the API's native value. Use `pageCount: -1` only when totals are genuinely unknown; in that mode, next-page availability requires application logic.

## Rendering

Use header groups and visible cells, not raw column definitions:

```tsx
<table>
  <thead>
    {table.getHeaderGroups().map((headerGroup) => (
      <tr key={headerGroup.id}>
        {headerGroup.headers.map((header) => (
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
```

Sorting controls should be actual buttons. Connect `column.getToggleSortingHandler()`, expose `column.getIsSorted()`, and set an appropriate `aria-sort` value on the header. Disable actions when `column.getCanSort()` is false.

## Feature Configuration

- Use `defaultColumn` for shared sizing and feature defaults, not repeated definitions.
- Use `columnVisibility`, `columnOrder`, `columnPinning`, and `columnSizing` as controlled state only when persistence or external controls require it.
- Use `enableSorting`, `enableColumnFilter`, and related column flags to prevent nonsensical operations.
- For selection, control `rowSelection`, use stable `getRowId`, and remember that `getSelectedRowModel()` can only materialize selected rows present in the supplied data. Store IDs when selection spans server pages.
- For large rendered row counts, combine Table with a virtualization library; virtualization is separate from Table's data transformations.
