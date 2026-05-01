# Mermaid Flowchart Syntax Reference

Use this file when the diagram needs more than basic nodes and arrows.

## Core Skeleton

```mermaid
flowchart TD
    A([Start]) --> B[Do something] --> C([End])
```

## Direction Keywords

| Keyword     | Direction     |
| ----------- | ------------- |
| `TD` / `TB` | Top to bottom |
| `LR`        | Left to right |
| `RL`        | Right to left |
| `BT`        | Bottom to top |

Prefer `TD` for process flows and `LR` for pipelines or timelines.

## Node Shapes

```mermaid
flowchart TD
    A[Rectangle]
    B(Rounded)
    C{Diamond}
    D([Stadium])
    E[[Subroutine]]
    F((Circle))
    G>Asymmetric]
    H[(Database)]
```

| Syntax     | Shape               | Typical use                |
| ---------- | ------------------- | -------------------------- |
| `[Text]`   | Rectangle           | Action / step              |
| `(Text)`   | Rounded rectangle   | Start / end                |
| `{Text}`   | Diamond             | Decision / condition       |
| `([Text])` | Stadium             | Terminal / event           |
| `[[Text]]` | Subroutine          | Subprocess / external call |
| `((Text))` | Circle              | Connector / junction       |
| `>Text]`   | Asymmetric          | Flag / signal              |
| `[(Text)]` | Cylinder / database | Data store                 |

## Edge Types

### Without labels

| Syntax | Style                 |
| ------ | --------------------- |
| `-->`  | Solid arrow           |
| `---`  | Solid line (no arrow) |
| `-.->` | Dotted arrow          |
| `-.-`  | Dotted line           |
| `==>`  | Thick arrow           |
| `===`  | Thick line            |

### With labels

```mermaid
flowchart TD
    A{Check} -->|Yes| B[Proceed]
    A -->|No| C[Stop]
    D --label text--> E
```

Both `-->|label|` and `--label-->` forms work. Pick one and stay consistent within a diagram.

## Subgraphs

```mermaid
flowchart TD
    subgraph Frontend["Frontend Layer"]
        A[Browser] --> B[React App]
    end
    subgraph Backend["Backend Layer"]
        C[API] --> D[DB]
    end
    B --> C
```

- Quote subgraph titles that contain spaces.
- Subgraphs can be nested, but avoid nesting deeper than one level.
- Edges can cross subgraph boundaries.

### Subgraph direction

```mermaid
flowchart TD
    subgraph Pipeline
        direction LR
        A[Parse] --> B[Transform] --> C[Load]
    end
```

Use `direction` inside a subgraph to override the parent chart direction.

## Styling

### Inline styles

```mermaid
flowchart TD
    A[Error] --> B[Retry]
    style A fill:#f99,stroke:#c00
```

### Class definitions

```mermaid
flowchart TD
    A[OK]:::success --> B[Fail]:::error
    classDef success fill:#9f9,stroke:#0a0
    classDef error fill:#f99,stroke:#c00
```

Use styling sparingly — only when visual distinction carries meaning (e.g., error vs success paths).

## Click / Links

```mermaid
flowchart TD
    A[Docs] --> B[API]
    click A href "https://example.com" "Open docs"
```

Avoid `click` with `callback` — it depends on the hosting environment and is fragile across renderers.

## Practical Constraints

- Keep node IDs short. Put readable text inside shape brackets.
- Keep edge labels to 2-4 words.
- Avoid more than ~15 nodes in a single diagram. Split into multiple charts instead.
- Diamond decisions should have exactly one edge per branch, each labeled.
- Stick to standard Mermaid flowchart syntax for better renderer compatibility.
- Test with `flowchart` directive, not the older `graph` alias, for access to newer features.
