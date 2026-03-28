# Editing Existing Draw.io XML

Use this guide when the user supplies an existing diagram and asks you to add, remove, move, restyle, or fix elements in it.

## Before Touching Anything

1. **Read the full XML.** Understand the existing structure before making changes. Note the root element (`mxGraphModel` or `mxfile`), the id scheme, parent-child relationships, containers, and any custom icon styles.
2. **Inventory the ids.** Scan every `id` attribute. Your new ids must not collide with any existing one. If the diagram uses numeric ids (`2`, `3`, `4`), continue the sequence. If it uses semantic ids (`api`, `db`, `worker`), follow that convention.
3. **Identify the parent structure.** Find which cells are top-level (`parent="1"`) and which are children of containers. This determines where new cells go and what coordinate system they use.

## Adding Nodes

- Match the style conventions already in the diagram. If existing boxes use `rounded=1;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;`, use the same style for new boxes of the same kind unless the user asks for something different.
- Place new nodes on the same 10px grid the diagram already uses.
- Respect existing spacing. Measure the gap between existing peers and use approximately the same distance.
- If adding inside a container, set `parent` to the container's id and use coordinates relative to that container's origin.

## Adding Edges

- Always include the expanded `mxGeometry` child:

```xml
<mxCell id="e-new" edge="1" parent="1" source="existing-node" target="new-node"
        style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- Match the edge style already used in the diagram. If the existing edges use `entityRelationEdgeStyle` or `elbowEdgeStyle`, continue with the same style unless the user asks to change it.
- Set `parent` to match the scope. If both source and target are inside the same container, parent the edge to that container.

## Removing Nodes

- Delete the `mxCell` (or `object`/`UserObject` wrapper) for the node.
- **Also delete every edge** that references the removed node as `source` or `target`. Orphan edges pointing at nonexistent ids will cause rendering errors.
- If the removed node was inside a container and was the only child, consider whether the empty container should also be removed or flagged to the user.

## Removing Edges

- Delete the `mxCell` for the edge. No cascading cleanup is needed — nodes survive without their edges.

## Moving and Repositioning

- To move a node, update the `x` and `y` in its `mxGeometry`. Snap to the 10px grid.
- To resize, update `width` and `height`.
- When moving a node that has edges, you usually do not need to update the edges — the auto-router recalculates paths from `source`/`target`. Only adjust edge waypoints (`Array` points inside `mxGeometry`) if the diagram has manually-routed edges and the new position would make them unreadable.
- When moving a node **into** a container, change its `parent` to the container's id and convert its coordinates from page-absolute to container-relative.
- When moving a node **out of** a container, change `parent` back to `"1"` and convert coordinates to page-absolute.

## Changing Labels

- Update the `value` attribute on the `mxCell` or the `label` attribute on an `object`/`UserObject`.
- Keep labels short. If the new label is significantly longer, consider widening the node.
- Escape XML-sensitive characters: `&amp;`, `&lt;`, `&gt;`, `&quot;`.

## Changing Styles

- Edit the `style` attribute string. Style entries are semicolon-separated key=value pairs ending with a trailing semicolon.
- To change a single property (e.g. fill color), find and replace just that key. Do not rewrite the entire style unless the user asks for a full restyle.
- Preserve any custom icon style verbatim. If the existing cell uses a `shape=mxgraph...` value, keep it exactly as-is unless the user explicitly asks to change the icon.

## Working With Containers

- To add a child to an existing container: create the new cell with `parent` set to the container's id, coordinates relative to the container.
- If adding children makes the container too small, expand its `width` and/or `height` to fit. Leave padding similar to what the existing children already have.
- To convert a plain node into a container: add `container=1;` to its style (or use `swimlane;startSize=30;`) and move child cells under it by changing their `parent`.

## Preserving What You Did Not Change

- Do not reformat or reorder XML that you are not modifying. Unnecessary diff noise makes it harder for the user to review your changes.
- Do not strip attributes you do not recognize. Custom metadata (`tooltip`, `placeholders`, `tags`, custom data attributes on `object`/`UserObject`) should be preserved.
- Do not change `mxGraphModel` attributes (`dx`, `dy`, `pageWidth`, `pageHeight`, etc.) unless the diagram needs a larger canvas to fit new content.

## Common Fix Patterns

### Missing `mxGeometry` on a vertex

Add the missing child:

```xml
<mxGeometry x="0" y="0" width="120" height="60" as="geometry" />
```

Pick coordinates that do not overlap existing nodes.

### Missing `mxGeometry` on an edge

Add the required relative geometry:

```xml
<mxGeometry relative="1" as="geometry" />
```

### Duplicate ids

Rename one of the duplicates. Update any `source`, `target`, or `parent` references that pointed at the renamed id.

### Orphan edge (source or target id does not exist)

Either delete the edge or fix the reference to point at the correct existing node. Ask the user if the intent is unclear.

### Structural cells missing

If cells `0` and `1` are absent, prepend them inside `<root>`:

```xml
<mxCell id="0" />
<mxCell id="1" parent="0" />
```

Then ensure all top-level elements have `parent="1"`.
