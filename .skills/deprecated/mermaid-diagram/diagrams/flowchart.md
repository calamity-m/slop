# Flowchart Diagram Lens

Use this lens when the triage step selects **flowchart**.

## Directive

- `flowchart TD` — top-down (default; best for step-by-step processes).
- `flowchart LR` — left-to-right (best for pipelines or timelines).

Use `TD` unless the flow is clearly horizontal in nature.

## Node Shapes

| Syntax      | Shape             | Typical use                |
| ----------- | ----------------- | -------------------------- |
| `A[Text]`   | Rectangle         | Action / step              |
| `A(Text)`   | Rounded rectangle | Start / end                |
| `A{Text}`   | Diamond           | Decision / condition       |
| `A([Text])` | Stadium           | Terminal / event           |
| `A[[Text]]` | Subroutine        | Subprocess / external call |
| `A((Text))` | Circle            | Connector / junction       |

Keep node IDs short (`A`, `B`, `C` or meaningful abbreviations). Put readable text inside the shape brackets.

## Edge Syntax

| Syntax             | Style                    |
| ------------------ | ------------------------ |
| `A --> B`          | Solid arrow              |
| `A --- B`          | Solid line (no arrow)    |
| `A -.-> B`         | Dotted arrow             |
| `A ==> B`          | Thick arrow              |
| `A -->\|label\| B` | Arrow with label         |
| `A --label--> B`   | Alternative label syntax |

Prefer `-->` for normal flow. Use `-.->` for optional or async paths. Use `==>` sparingly for emphasis.

## Subgraphs

```mermaid
flowchart TD
    subgraph Auth["Authentication"]
        A[Check token] --> B{Valid?}
    end
    subgraph App["Application"]
        C[Process request] --> D[Return response]
    end
    B -->|Yes| C
```

Use subgraphs to group related steps. Do not nest subgraphs more than one level deep.

## Decision Diamond Patterns

### Simple if/else

```mermaid
flowchart TD
    A[Receive request] --> B{Authenticated?}
    B -->|Yes| C[Process request]
    B -->|No| D[Return 401]
```

### Multi-branch

```mermaid
flowchart TD
    A[Parse input] --> B{Input type?}
    B -->|JSON| C[Parse JSON]
    B -->|XML| D[Parse XML]
    B -->|Other| E[Reject]
    C --> F[Validate]
    D --> F
```

## Common Patterns

### Linear flow

```mermaid
flowchart TD
    A([Start]) --> B[Step 1] --> C[Step 2] --> D[Step 3] --> E([Done])
```

### Parallel merge

```mermaid
flowchart TD
    A[Start] --> B[Task A]
    A --> C[Task B]
    B --> D[Merge results]
    C --> D
```

### Subprocess grouping

```mermaid
flowchart LR
    A[Request] --> B[[Validate]]
    B --> C[[Transform]]
    C --> D[[Persist]]
    D --> E[Response]
```

## Flowchart Validation Checklist

- Every node ID used in an edge is defined somewhere in the diagram.
- Decision diamonds have labeled edges for each branch.
- Subgraphs have quoted titles when they contain spaces.
- No orphan nodes (every node connects to at least one edge).
- Direction (`TD`/`LR`) matches the natural reading order of the flow.
- The diagram still reads after removing any decorative subgraph or styling.

For full syntax details, see [../references/flowchart-syntax.md](../references/flowchart-syntax.md).
