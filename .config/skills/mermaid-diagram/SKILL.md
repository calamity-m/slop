---
name: mermaid-diagram
description: Create or repair Mermaid diagrams (sequence, flowchart, ERD, and more) from prose, code paths, architecture notes, database schemas, or process descriptions. Use this skill when the user asks for a Mermaid diagram, interaction flow, process chart, decision tree, entity relationship diagram, data model, schema diagram, or wants existing Mermaid syntax cleaned up or made easier to read.
---

# Mermaid Diagram

Turn a description into valid, readable Mermaid diagram code.

Keep the output simple. Prefer the smallest diagram that still explains the behavior.

## Workflow

1. **Determine diagram type.** Use the triage heuristics below to pick the right type. If ambiguous, ask the user.
2. **Load the diagram lens** from `diagrams/<type>.md`.
3. **Identify actors, nodes, or entities** and the relationships between them.
4. **Shape for readability** — left-to-right for sequence participants, top-to-bottom or left-to-right for flowcharts, and minimal entities with clear cardinalities for ERDs.
5. **Write the core structure first.**
6. **Add control-flow or attribute detail** (`alt`, `opt`, `loop`, `par`, decision diamonds, subgraphs, key markers) only when it materially improves understanding.
7. **Validate** with `scripts/validate.sh`, then do a final syntax pass to remove invalid or overly clever constructs.

If the source flow is ambiguous, state the assumption before the diagram.

## Triage — Choosing a Diagram Type

| Signal in user request | Diagram type |
|---|---|
| Interactions between actors/systems, message flows, API calls, request/response, handshakes, async jobs, webhooks | **sequence** |
| Decision trees, process flows, branching logic, steps with conditions, workflow routing, state transitions | **flowchart** |
| Tables, entities, schema relationships, foreign keys, cardinality, one-to-many/many-to-many data modeling | **erd** |

If the request fits both (e.g. a flow with both actor interactions and branching decisions), prefer the type that best serves the primary concern. If truly ambiguous, ask.

## Universal Output Rules

- Use short labels. Alias long names.
- Prefer explicit verbs in labels: `Validate token`, `Persist order`, `Publish event`.
- For ERDs, include only the entities, attributes, and key markers needed to answer the question.
- Use notes or comments sparingly. If a note replaces three or more noisy constructs, it is probably worth it.
- Do not encode business logic in label text. Show the interaction or flow, not the whole implementation.
- Avoid renderer-fragile tricks or nonstandard syntax. Use standard Mermaid features only.
- Split into two diagrams instead of making one giant chart when there are two unrelated concerns.

## Diagram-Shaping Heuristics

- Collapse incidental infrastructure if it does not affect the decision being explained.
- Split over nesting — prefer two smaller diagrams over one deeply nested one.
- Show failures explicitly with `alt` branches or separate paths, not buried in note text.
- Prefer duplication over a deeply nested diagram that becomes hard to read.

## Validation

Before finalizing:

- If the diagram exists as a local file or can be written to a temp file, run `./scripts/validate.sh <diagram-file>`.
- If the diagram is in Markdown, extract the Mermaid block first or write just the Mermaid snippet to a temp file before validating.
- Run through the type-specific validation checklist in the diagram lens.
- Check that labels are short enough to scan without wrapping badly.
- Check that the diagram still reads after removing any decorative element.

For wording, escaping, and readability guidance, read [references/best-practices.md](./references/best-practices.md).

## Resources

### diagrams/

- `diagrams/sequence.md`: Sequence diagram lens — participants, arrows, control flow, common patterns.
- `diagrams/flowchart.md`: Flowchart diagram lens — nodes, edges, subgraphs, decision patterns.
- `diagrams/erd.md`: ERD lens — entities, cardinality, attributes, and schema modeling patterns.

### references/

- `references/best-practices.md`: Universal parser safety and readability guidance for all diagram types.
- `references/sequence-syntax.md`: Complete Mermaid sequence diagram syntax reference.
- `references/flowchart-syntax.md`: Complete Mermaid flowchart syntax reference.
- `references/erd-syntax.md`: Complete Mermaid ERD syntax reference.

### scripts/

- `scripts/validate.sh`: Validate Mermaid diagram syntax by rendering with `npx @mermaid-js/mermaid-cli`.
