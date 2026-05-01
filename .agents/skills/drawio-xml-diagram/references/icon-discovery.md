# Icon Discovery

Custom draw.io icon libraries are not portable unless you have the exact style string or XML fragment used by the target instance.

Start every skill invocation by asking for the icon set. Use this contract:

```text
generic shapes
```

or

```text
library: AWS
icons:
- api-gateway: <full style string or full cell XML>
- eks-cluster: <full style string or full cell XML>
- rds-postgres: <full style string or full cell XML>
```

## How The User Can Find The Exact Icon Style

### Option 1: Copy The Style String

1. Open draw.io and place the exact icon on the canvas.
2. Right-click the icon and choose `Edit Style`.
3. Copy the full `key=value;` style string.
4. Paste it back with a short name if helpful.

This is the fastest path when the icon is a normal shape and the style string fully describes it.

## Option 2: Copy The Full Cell XML

Use this when the icon style is not obvious, the icon carries metadata, or the user is unsure whether the style string alone is enough.

1. Open draw.io and place the exact icon on the canvas.
2. Select `Extras > Edit Diagram`.
3. Find the icon's `<mxCell>`, `<object>`, or `<UserObject>` entry.
4. Copy the full XML fragment for that icon.

This is the most reliable path because it preserves wrapper metadata and any non-obvious attributes.

## When The User Already Has A Diagram

- Ask them to open the existing diagram, select the icon, and use `Edit Style`, or open `Extras > Edit Diagram` and copy the matching XML fragment.
- If several icons share similar names, ask for a short alias for each one so the final diagram request stays readable.

## What Not To Accept As Exact Enough

- A screenshot alone
- A library name alone, such as "AWS 2024" or "Kubernetes"
- A human description like "the blue EKS icon"

Those inputs are useful for intent, but not reliable enough for exact XML reproduction.

## Fallback

If the user cannot provide exact icon styles or XML:

- offer generic shapes with clear labels
- keep the diagram structurally correct
- mention that icon substitution can be done later once the exact styles are available
