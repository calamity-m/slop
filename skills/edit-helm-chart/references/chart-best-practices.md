# Helm Chart Editing Best Practices

Use this file when deciding where a change should live or when a chart starts getting too clever.

## Prefer Values Over Template Logic

- Put configuration in `values.yaml`.
- Keep templates focused on rendering manifests, not computing business rules.
- If a value is user-tunable, surface it clearly instead of hiding it in a helper.
- Do not turn every possible Kubernetes field into a chart value. Generic infrastructure charts with huge `values.yaml` files usually become hard to understand and easy to misuse.

## Prefer Simple To Complex

- Start with the smallest chart that satisfies the stated requirement.
- Do not add HPA, PodDisruptionBudget, affinity, tolerations, sidecars, or other optional infrastructure features unless the user or the existing chart clearly needs them.
- Add complexity when it becomes real, not when it is merely imaginable.
- If a team starts needing autoscaling later, add it then. Do not pre-bake it into every chart just in case.

## Keep Templates Readable

- Prefer a few named local variables over long pipelines.
- Use `with` to reduce repetition when rendering nested values.
- Use `toYaml` and `nindent` for maps and lists instead of hand-indenting blocks.
- Avoid deeply nested `if` and `range` blocks.

## Use Helpers Sparingly

- Reuse an existing helper if it already establishes naming, labels, or selector conventions.
- Add a helper when it removes repeated manifest noise across multiple templates.
- Do not hide simple one-line logic in `_helpers.tpl` just because you can.

## Be Careful With Defaults

- Keep defaults safe for local rendering.
- Prefer explicit `required` only for values that truly must be supplied by the caller.
- Quote strings that may be misread by YAML or Kubernetes parsers.

## Respect Existing Chart Shape

- Match the chart’s existing file layout unless there is a clear maintenance problem.
- Do not rename labels, selectors, or resource names casually.
- Treat changes to selectors and immutable fields as breaking unless proven otherwise.

## Prefer Resource-Oriented Template Files

- When creating or reshaping templates, bias toward files named by resource kind such as `deployment.yaml`, `service.yaml`, and `configmap.yaml`.
- Avoid large per-service template files such as `service-a.yaml` that mix many resource types together unless the chart already has a strong reason to be organized that way.
- Keep related manifests near each other, but let the file names tell the reader what Kubernetes resource they are opening.

## Validate the Way the Chart Is Really Used

- Run lint after each meaningful change.
- Render the chart with the same values files or `--set` overrides that matter in practice.
- If a chart has multiple environments, validate the environment touched by the edit instead of pretending the defaults are enough.
- Always render `HEAD` and the working tree with the same Helm inputs and diff the outputs instead of guessing.
- When reporting results to the user, do not dump a giant manifest diff unless it is genuinely small enough to read.
- Prefer a concise summary grouped by changed resource kinds and the behavior that changed.
