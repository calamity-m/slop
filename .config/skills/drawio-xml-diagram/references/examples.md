# Examples

These examples are intentionally small. Use them as patterns, not as a fixed template.

## Example 1: Minimal Service Call

```xml
<mxGraphModel dx="0" dy="0" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1200" pageHeight="700" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="api" value="API" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;" vertex="1" parent="1">
      <mxGeometry x="140" y="180" width="140" height="70" as="geometry" />
    </mxCell>
    <mxCell id="db" value="Database" style="shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="1">
      <mxGeometry x="420" y="180" width="140" height="80" as="geometry" />
    </mxCell>
    <mxCell id="e1" value="reads and writes" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;endArrow=classic;" edge="1" parent="1" source="api" target="db">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```

## Example 2: Decision Flow

```xml
<mxGraphModel dx="0" dy="0" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1200" pageHeight="900" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="start" value="Start" style="ellipse;whiteSpace=wrap;html=1;fillColor=#D5E8D4;strokeColor=#82B366;" vertex="1" parent="1">
      <mxGeometry x="220" y="80" width="120" height="60" as="geometry" />
    </mxCell>
    <mxCell id="check" value="Token valid?" style="rhombus;whiteSpace=wrap;html=1;fillColor=#FFE6CC;strokeColor=#D79B00;" vertex="1" parent="1">
      <mxGeometry x="210" y="220" width="140" height="100" as="geometry" />
    </mxCell>
    <mxCell id="allow" value="Serve request" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;" vertex="1" parent="1">
      <mxGeometry x="470" y="235" width="150" height="70" as="geometry" />
    </mxCell>
    <mxCell id="deny" value="Return 401" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#F8CECC;strokeColor=#B85450;" vertex="1" parent="1">
      <mxGeometry x="20" y="235" width="150" height="70" as="geometry" />
    </mxCell>
    <mxCell id="e-start" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;endArrow=classic;" edge="1" parent="1" source="start" target="check">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="e-yes" value="yes" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;endArrow=classic;" edge="1" parent="1" source="check" target="allow">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="e-no" value="no" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;endArrow=classic;" edge="1" parent="1" source="check" target="deny">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```

## Example 3: Container With Relative Child Coordinates

```xml
<mxGraphModel dx="0" dy="0" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1400" pageHeight="900" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="svc" value="Payments Service" style="swimlane;startSize=30;html=1;rounded=1;fillColor=#F5F5F5;strokeColor=#666666;" vertex="1" parent="1">
      <mxGeometry x="140" y="140" width="420" height="220" as="geometry" />
    </mxCell>
    <mxCell id="api" value="REST API" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;" vertex="1" parent="svc">
      <mxGeometry x="30" y="60" width="150" height="70" as="geometry" />
    </mxCell>
    <mxCell id="worker" value="Worker" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#D5E8D4;strokeColor=#82B366;" vertex="1" parent="svc">
      <mxGeometry x="230" y="60" width="150" height="70" as="geometry" />
    </mxCell>
    <mxCell id="e1" value="enqueue job" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;endArrow=classic;" edge="1" parent="svc" source="api" target="worker">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```

## Example 4: Custom Icon Handoff Template

This pattern is only safe after `USER_SUPPLIED_STYLE_STRING` has been replaced with the exact style copied from the user's draw.io instance.

```xml
<mxGraphModel dx="0" dy="0" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1200" pageHeight="800" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="icon-1" value="EKS Cluster" style="USER_SUPPLIED_STYLE_STRING" vertex="1" parent="1">
      <mxGeometry x="180" y="180" width="80" height="80" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
```

If the user provided a full `<object>` or `<UserObject>` fragment instead of just a style string, preserve that wrapper and replace only the geometry, parent, and visible label when needed.
