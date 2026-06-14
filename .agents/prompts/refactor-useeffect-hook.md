---
description: Refactor a useEffect hook in a react codebase to not use useEffect anymore
argument-hint: "<hook-to-refactor>"
---

# Refactor React `useEffect` Hook Away From Effect-Based State

You are refactoring a React component that currently uses `useEffect` in a way that may cause unnecessary re-renders, derived state duplication, or performance issues.

## Goal

Refactor the component so that the relevant logic no longer relies on `useEffect` unless it is genuinely synchronizing with an external system.

Focus especially on:

- Avoiding unnecessary render → effect → state update → re-render cycles
- Removing derived state that can be calculated during render
- Improving re-render performance
- Keeping behaviour equivalent
- Making the code easier to reason about

## Key Principle

Before keeping any `useEffect`, ask:

> Is this effect synchronizing React with something outside React?

Examples where `useEffect` may be valid:

- Subscribing/unsubscribing to browser APIs
- Fetching data
- Setting up timers
- Integrating with non-React libraries
- Imperative DOM interactions
- Persisting to localStorage/sessionStorage
- WebSocket/event listener setup

Examples where `useEffect` should usually be removed:

- Copying props into state
- Computing filtered/sorted/mapped data
- Updating state based on other state
- Deriving display values
- Resetting values that can be controlled directly by event handlers
- Triggering internal state updates only because another React value changed

## Refactoring Strategy

Inspect the existing `useEffect` and classify it into one of these categories:

### 1. Derived State

If the effect calculates one value from props/state and stores it in state, remove the state and compute it directly.

Prefer:

```tsx
const filteredItems = useMemo(() => {
  return items.filter((item) => item.enabled);
}, [items]);
```

Or, if cheap:

```tsx
const filteredItems = items.filter((item) => item.enabled);
```

Avoid:

```tsx
const [filteredItems, setFilteredItems] = useState([]);

useEffect(() => {
  setFilteredItems(items.filter((item) => item.enabled));
}, [items]);
```

### 2. Event-Driven Updates

If the effect reacts to state changes that were caused by user actions, move the update into the event handler.

Prefer:

```tsx
function handleSelectionChange(nextSelection: Selection) {
  setSelection(nextSelection);
  setExpandedIds(calculateExpandedIds(nextSelection));
}
```

Avoid:

```tsx
useEffect(() => {
  setExpandedIds(calculateExpandedIds(selection));
}, [selection]);
```

### 3. Expensive Calculations

If the effect exists to avoid recalculating something expensive, replace it with `useMemo`.

Use `useMemo` only when:

- The calculation is non-trivial
- The inputs are stable enough to benefit from memoization
- It prevents meaningful repeated work during renders

Example:

```tsx
const groupedRows = useMemo(() => {
  return groupRowsByCategory(rows);
}, [rows]);
```

### 4. Function Identity / Child Re-renders

If callbacks are causing child components to re-render unnecessarily, use `useCallback` where it helps.

Example:

```tsx
const handleRowClick = useCallback((rowId: string) => {
  setSelectedRowId(rowId);
}, []);
```

Only use `useCallback` when the function is passed to memoized children or used as a dependency elsewhere.

### 5. Object / Array Identity

If object or array props are recreated on every render and causing memoized children to re-render, stabilize them with `useMemo`.

Example:

```tsx
const tableOptions = useMemo(
  () => ({
    pageSize,
    sortOrder,
    filters,
  }),
  [pageSize, sortOrder, filters],
);
```

### 6. External Synchronization

If the effect truly synchronizes with an external system, keep it, but make sure it is minimal.

A valid effect should:

- Have the smallest possible dependency list
- Avoid setting React state unless required
- Clean up subscriptions/listeners/timers
- Not duplicate values that React can derive during render

Example:

```tsx
useEffect(() => {
  const unsubscribe = externalStore.subscribe(handleExternalChange);
  return unsubscribe;
}, [handleExternalChange]);
```

## Required Process

Please perform the refactor in stages:

1. Identify every `useEffect` in the target component.
2. Explain what each effect currently does.
3. Classify each effect as:
   - derived state
   - event-driven state update
   - expensive calculation
   - external synchronization
   - unnecessary / removable
   - unclear

4. For each effect, decide whether to:
   - remove it
   - replace it with render-time calculation
   - replace it with `useMemo`
   - replace it with `useCallback`
   - move logic into an event handler
   - keep it as a real external synchronization effect

5. Refactor the code.
6. Ensure behaviour is equivalent.
7. Look specifically for render loops, extra state updates, unstable dependency arrays, and unnecessary object/function recreation.
8. Add comments only where they clarify non-obvious decisions.

## Performance Focus

Prioritise reducing unnecessary re-renders by:

- Removing redundant state
- Avoiding chained state updates
- Avoiding effects that immediately call `setState`
- Stabilizing expensive derived values
- Stabilizing props passed to memoized children
- Avoiding new object/array/function identities where they matter
- Keeping state as close as possible to the place it is actually modified
- Avoiding premature memoization for cheap calculations

Do not blindly add `useMemo` or `useCallback` everywhere. Use them only where they reduce meaningful work or prevent avoidable child re-renders.

## Things To Watch For

Check carefully for these anti-patterns:

```tsx
useEffect(() => {
  setX(computeX(y));
}, [y]);
```

Prefer:

```tsx
const x = computeX(y);
```

Or:

```tsx
const x = useMemo(() => computeX(y), [y]);
```

---

```tsx
useEffect(() => {
  setState(props.value);
}, [props.value]);
```

Prefer controlled state, direct props usage, or explicit reset logic.

---

```tsx
useEffect(() => {
  setSomething(value);
}, [value]);
```

This is often just duplicating state and causing an extra render.

---

```tsx
useEffect(() => {
  if (someCondition) {
    setA(...);
    setB(...);
  }
}, [someCondition]);
```

Consider whether this belongs in the event handler that caused `someCondition` to change.

## Output Format

Please provide:

1. A short summary of what changed.
2. The before/after reasoning for each removed or changed `useEffect`.
3. The refactored code.
4. Any trade-offs or assumptions.
5. Any areas where behaviour may need manual testing.

## Constraints

- Preserve existing public behaviour.
- Do not change unrelated component logic.
- Do not introduce new libraries unless absolutely necessary.
- Prefer simple React patterns over clever abstractions.
- Keep TypeScript types correct.
- Keep the diff focused.
- Do not silence ESLint hook dependency warnings by disabling rules unless there is a very strong reason.
- If a dependency is unstable, fix the unstable dependency rather than hiding the warning.

## Target Code

Hook: $ARGUMENTS
