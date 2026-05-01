# Draw.io XML Rules

Use these rules when generating raw draw.io XML.

## Canonical Single-Page Form

Prefer a bare `mxGraphModel` for single-page output:

```xml
<mxGraphModel dx="0" dy="0" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1600" pageHeight="900" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
  </root>
</mxGraphModel>
```

Use full `mxfile` wrapping only when the user explicitly needs:

- multiple pages
- file-level `vars`
- a literal `.drawio` wrapper instead of the inner graph model

## Structural Rules

- Always include structural cells `0` and `1`.
- Keep all ids unique within a diagram.
- Use `vertex="1"` for shapes and `edge="1"` for connectors. Do not set both.
- Give every vertex an `mxGeometry` child with `x`, `y`, `width`, and `height`.
- Give every edge an expanded `mxGeometry` child with `relative="1"` and `as="geometry"`.
- Keep XML uncompressed. Do not emit deflated/Base64 diagram content.

## Styles

- Default box style: `rounded=1;whiteSpace=wrap;html=1;`
- Common fill and stroke pair:
  - `fillColor=#DAE8FC;strokeColor=#6C8EBF;`
- Common connector style:
  - `edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;`
- Use explicit `shape=` only when it materially improves the diagram.
- For non-rectangular shapes, ensure the style is coherent with the perimeter and label behavior.

## Labels And Escaping

- Use short labels that can fit without awkward wrapping.
- Escape XML-sensitive characters inside attributes: `&amp;`, `&lt;`, `&gt;`, `&quot;`.
- Avoid HTML in edge labels unless it is absolutely necessary.
- Never use `--` inside XML comments.

## Layout

- Snap coordinates to the 10px grid.
- Prefer readable spacing over compactness.
- Start with left-to-right or top-to-bottom flow based on how the user will read the diagram.
- Use waypoints only when the auto-router would create overlap or ambiguity.

## Containers And Groups

- Use parent-child containment instead of visually stacking children on top of a larger box.
- For titled containers, use `swimlane;startSize=30;`.
- For untitled containers, use a box with `container=1;pointerEvents=0;`.
- Children inside a container use coordinates relative to that container.

## Custom Icons

- Assume the target draw.io instance already has the needed libraries available.
- Never guess an AWS, Kubernetes, Azure, GCP, or internal icon style string.
- Reuse the exact style string or XML fragment supplied by the user.
- If the user provides a full `<object>` / `<UserObject>` fragment, preserve the wrapper and only adjust label, geometry, and parent as needed.
