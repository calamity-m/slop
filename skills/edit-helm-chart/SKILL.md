---
name: edit-helm-chart
description: Edit existing Helm charts by changing `Chart.yaml`, `values.yaml`, templates, helpers, or dependency settings, then validate the result with Helm. Use this skill when the user asks to modify a Helm chart, add or remove chart values, update Kubernetes manifests generated from templates, fix Helm lint or render errors, adjust helper templates, or make a chart easier to maintain without breaking rendering.
---

# Edit Helm Chart

Edit Helm charts conservatively and validate every change with Helm.

Prefer the smallest change that preserves the chart's current structure and naming conventions.

## Workflow

1. Identify the chart root by finding `Chart.yaml`.
2. Read `Chart.yaml`, `values.yaml`, and only the templates and helpers relevant to the requested change.
3. Decide whether the change belongs in `values.yaml`, a template, `_helpers.tpl`, or dependency metadata.
4. Make the smallest coherent edit.
5. Run `./scripts/validate.sh <chart-dir> [helm args...]`.
6. If validation fails, fix the chart before stopping.

## Editing Rules

- Put user-tunable settings in `values.yaml` unless there is a good reason not to.
- Do not make every single thing configurable by default. A giant `values.yaml` full of rarely used knobs usually makes the chart worse, not better.
- Build charts simple to complex. Add configuration only when the user or the real deployment shape asks for it.
- Do not add optional Kubernetes features just because the platform supports them. If the user did not ask for HPA, do not quietly add HPA.
- Grow complexity in bites. When a new need appears later, add that capability then instead of preemptively designing for it now.
- Keep template logic shallow. If a template starts looking like a programming language, back up.
- Reuse existing helpers before adding a new one.
- Add a new helper only when the same pattern appears in multiple places or hides real complexity.
- Preserve existing labels, selectors, and names unless the user explicitly wants a breaking change.
- Quote strings that may contain special characters, booleans-that-are-not-booleans, or numeric-looking identifiers.
- Use `default`, `required`, `include`, `toYaml`, `nindent`, and `with` carefully. Prefer readable templates over clever pipelines.
- Keep conditionals near the manifest block they control.
- Avoid moving values between files unless the payoff is clear.
- When shaping or refactoring templates, prefer resource-oriented files such as `deployment.yaml`, `service.yaml`, and `configmap.yaml` over large per-service grab bags such as `service-a.yaml`, unless the existing chart already has a strong pattern worth preserving.

## Common Tasks

### Add or update a configurable value

- Add the value in `values.yaml`.
- Thread it into the specific template that needs it.
- Keep the default safe and unsurprising.

### Add a new manifest

- Follow the naming and helper patterns already present in the chart.
- Copy the smallest nearby template that matches the resource shape.
- Parameterize only the fields users are likely to need.
- Do not introduce feature toggles for future maybe-requirements.

### Fix a rendering bug

- Reproduce the render or lint failure first.
- Change as little as possible.
- Re-run validation immediately after the fix.

### Update dependencies

- Edit `dependencies` in `Chart.yaml`.
- If the repo uses vendored charts or lockfiles, update only what the repo’s existing pattern requires.
- Avoid introducing dependency updates unless the user asked for them.

## Validation

- Use `./scripts/validate.sh <chart-dir>` after every meaningful change.
- Pass the same `-f`, `--set`, `--values`, `--namespace`, or other Helm arguments the user cares about so validation matches the intended render path.
- Treat `helm lint` and `helm template` as the minimum bar.

For chart-editing patterns and guardrails, read [references/chart-best-practices.md](./references/chart-best-practices.md).

## Resources

### scripts/

- `scripts/validate.sh`: run `helm lint` and `helm template` against a chart, forwarding additional Helm arguments to both commands.

### references/

- `references/chart-best-practices.md`: guidance for where to put values, how to keep templates readable, and what mistakes usually make charts painful to maintain.
