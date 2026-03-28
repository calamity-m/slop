# Sequence Diagram Lens

Use this lens when the triage step selects **sequence**.

## Directive

Start with `sequenceDiagram`.

## Participants

- Use `actor` for humans or external operators, `participant` for systems.
- Declare participants near the top for clarity: `participant API as Payments API`.
- Prefer stable participant names across the whole diagram.
- Keep names short — alias long names.

## Arrow Styles

| Arrow | Meaning |
|---|---|
| `->>` | Message / request |
| `-->>` | Return / response |
| `-x` | Stop or failed delivery |
| `--x` | Failed return or terminated response |

Prefer `->>` and `-->>` unless a failure marker makes the diagram materially clearer.

## Activations

- Use activations when call duration, nested work, or temporary ownership of a task matters to the explanation.
- Prefer arrow-suffix shorthand for simple request/response lifecycles: `App->>+API` and `API-->>-App`.
- Use explicit `activate` / `deactivate` lines when the shorthand makes a dense sequence harder to read.
- Skip activations when they do not change how the reader understands the flow.

## Control Flow

- `alt` / `else` — conditional branches. Show failures here instead of burying them in notes.
- `opt` — optional path.
- `loop` — retries or repeated steps.
- `par` / `and` — concurrent work (only when concurrency matters to the explanation).
- `critical` / `option` — exactly-once semantics (use sparingly; `alt` is more familiar).

Use `autonumber` only when step numbering helps discussion or review.

## Common Patterns

### Request and response

```mermaid
sequenceDiagram
    actor User
    participant App
    participant API
    participant DB

    User->>App: Submit form
    App->>API: POST /orders
    API->>DB: Insert order
    DB-->>API: Order id
    API-->>App: 201 Created
    App-->>User: Show confirmation
```

### Conditional branch

```mermaid
sequenceDiagram
    actor User
    participant API
    participant Auth

    User->>API: Request protected resource
    API->>Auth: Validate token
    alt token valid
        Auth-->>API: Claims
        API-->>User: 200 OK
    else token invalid
        Auth-->>API: Reject
        API-->>User: 401 Unauthorized
    end
```

### Async handoff

```mermaid
sequenceDiagram
    actor User
    participant API
    participant Queue
    participant Worker
    participant Email

    API->>Queue: Enqueue welcome job
    API-->>User: 202 Accepted
    Worker->>Queue: Pull job
    Worker->>Email: Send welcome email
    Email-->>Worker: Sent
```

### Nested call with activations

```mermaid
sequenceDiagram
    participant App
    participant API
    participant DB

    App->>+API: Load order
    API->>+DB: Query order
    DB-->>-API: Order row
    API-->>-App: Render order
```

## Sequence Validation Checklist

- Every participant is declared or introduced consistently.
- Every `alt`, `opt`, `loop`, `par`, `critical`, or `rect` block has a matching `end`.
- Activation shortcuts and `activate` / `deactivate` statements balance cleanly.
- Arrow direction matches the intended sender and receiver.
- Labels are short enough to scan without wrapping badly.
- The diagram still reads after removing any decorative note or branch.

For full syntax details, see [../references/sequence-syntax.md](../references/sequence-syntax.md).
