---
name: drawio-xml-diagram
description: Create or repair raw draw.io / diagrams.net XML diagrams in `mxGraphModel` or uncompressed `.drawio` form. Use when the user wants draw.io XML, diagrams.net source, `mxGraphModel`, `.drawio` source, or a diagram that will be pasted into or uploaded to a draw.io instance, especially when it must reuse icon libraries already installed in that instance.
---

# Draw.io XML Diagram

Create valid, uncompressed draw.io XML that a user can paste into `Extras > Edit Diagram` or save as `.drawio` / `.xml` and open in draw.io.

Default to a single-page bare `<mxGraphModel>` document. Use full `<mxfile>` wrapping only when the user explicitly needs multiple pages, file-level `vars`, or a literal `.drawio` wrapper.

## Start With Icons

Begin every invocation by asking which icons or shape libraries the diagram must use.

Use this prompt pattern unless the user already supplied the information:

```text
Which icons or shape libraries should this diagram use?

- If generic draw.io shapes are fine, say: generic shapes
- If you want custom libraries such as AWS, Kubernetes, Azure, GCP, or internal icons, paste either:
  1. the full style string from Edit Style (`Ctrl+E` / `Cmd+E`), or
  2. the full `<mxCell>` / `<object>` XML fragment from Extras > Edit Diagram

You can also give each icon a short name, for example:
- eks-cluster: <style string or cell XML>
- rds-postgres: <style string or cell XML>
- public-lb: <style string or cell XML>
```

Do not guess custom library identifiers. If the user only says "use Kubernetes icons" or "use AWS icons", stop and ask for the exact style strings or cell XML needed for the requested icons. If the user cannot provide them, offer to continue with generic shapes and labels instead.

## Workflow

1. Confirm the diagram goal, the nodes, relationships, and any groupings or containers.
2. Resolve the icon contract first. Preserve user-supplied icon styles verbatim.
3. Choose the smallest valid XML form:
   - bare `<mxGraphModel>` for most single-page diagrams
   - full `<mxfile>` only for multiple pages, `vars`, or when explicitly requested
4. Lay out the diagram before writing XML:
   - use a 10px grid
   - leave generous spacing
   - keep connectors readable
   - use parent-child containment for grouped content
5. Generate uncompressed XML only.
6. Validate with the skill's validator when local execution is available, then do a final manual pass.

## Output Rules

- Return raw XML only. Do not generate PNG, SVG, PDF, Mermaid, or CSV.
- Prefer one page. Use multiple pages only when the user explicitly asks for them. If one page would be unreadable, ask whether the user wants a multi-page `mxfile` or a narrower single-page diagram.
- Always include the structural cells:
  - `<mxCell id="0"/>`
  - `<mxCell id="1" parent="0"/>`
- Use unique `id` values across the diagram.
- Give every edge an expanded `mxGeometry` child:

```xml
<mxCell id="e1" edge="1" parent="1" source="a" target="b" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- Escape XML/HTML correctly in labels: `&amp;`, `&lt;`, `&gt;`, `&quot;`.
- Keep comments legal XML. Never use `--` inside comments.
- Do not invent `shape=mxgraph...` values for icon libraries. Only use exact user-supplied styles or fragments.
- When the user provides a full `<object>` / `<UserObject>` / `<mxCell>` fragment for an icon, keep the wrapper structure and metadata unless there is a clear reason to remove it.
- When custom icons are missing exact style data, fall back to generic shapes or ask for the missing data before writing XML.

## Layout Heuristics

- Prefer `edgeStyle=orthogonalEdgeStyle` for most architecture and flow diagrams.
- Use `rounded=1;whiteSpace=wrap;html=1;` as the default box style unless the diagram type suggests something else.
- Leave roughly 160-220px horizontal space and 100-140px vertical space between boxes in dense diagrams.
- Use `swimlane;startSize=30;` or a custom `container=1;pointerEvents=0;` container for grouped systems.
- Children of containers use coordinates relative to the container, not the page.
- Avoid crossing edges if a small position change or waypoint solves it.
- Use labels and icon names sparingly. The diagram should still read if a viewer does not have the same icon library enabled.

## Validation

When local execution is available, validate the XML with the skill's own script. The script lives in the skill directory, not the user's project.

```bash
python3 <skill-dir>/scripts/validate-xml.py <diagram-file.xml>
```

The validator:

- parses the XML
- accepts either bare `<mxGraphModel>` or full `<mxfile>`
- checks structural cells, unique ids, vertex geometry, and edge geometry
- uses the bundled `references/mxfile.xsd` through `xmllint` when `xmllint` is available

If shell execution is not available, do this checklist manually:

- root element is `mxGraphModel` or `mxfile`
- structural cells `0` and `1` exist and `1` has `parent="0"`
- every `vertex="1"` cell has `mxGeometry`
- every `edge="1"` cell has `<mxGeometry relative="1" as="geometry" />`
- every id is unique
- any custom icon style came from the user, not from a guess

## References

- Read [references/xml-rules.md](./references/xml-rules.md) for the canonical XML shape, containment rules, and style heuristics.
- Read [references/icon-discovery.md](./references/icon-discovery.md) when the user wants AWS, Kubernetes, Azure, GCP, or internal icon libraries.
- Read [references/examples.md](./references/examples.md) for small working XML examples and a custom-icon handoff template.
- Use [references/mxfile.xsd](./references/mxfile.xsd) as the bundled schema reference.

## Resources

### scripts/

- `scripts/validate-xml.py`: validate bare `mxGraphModel` or full `mxfile` XML with structural checks and optional XSD validation.

### references/

- `references/xml-rules.md`: compact draw.io XML rules and generation heuristics.
- `references/icon-discovery.md`: how to ask for and extract exact icon/style identifiers from the user's draw.io instance.
- `references/examples.md`: concise example diagrams and a template for user-supplied icon styles.
- `references/mxfile.xsd`: official draw.io XML schema copied from `https://www.drawio.com/assets/mxfile.xsd`.
