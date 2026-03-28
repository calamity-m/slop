---
name: exec-plan-setup
description: Set up or refresh the ExecPlan / `PLANS.md` workflow described in OpenAI's Codex cookbook by creating or updating `AGENTS.md`, a shared `PLANS.md` guide, and optional starter ExecPlan files. Use when the user wants to adopt `PLANS.md`, ExecPlans, execution plans, long-running design docs, or the OpenAI cookbook planning pattern in a repository.
---

# ExecPlan Setup

Set up the repository so agents know when to use ExecPlans and so the repo contains a reusable `PLANS.md` guide plus a starter ExecPlan template.

This skill is for bootstrap and alignment, not for implementing the feature itself. After setup, the user can ask for a specific ExecPlan and the repo will already contain the shared rules.

## Workflow

1. Inspect the repo root for `AGENTS.md`, `PLANS.md`, `.agent/PLANS.md`, and any other planning docs.
2. Choose the plan-path convention:
   - If the repo already references a plan path in `AGENTS.md`, keep that path.
   - Else if the repo already has `PLANS.md`, keep it.
   - Else default to `PLANS.md` at the repo root for visibility and simplicity.
   - Use `.agent/PLANS.md` only if the repo already has an `.agent/` convention or the user explicitly wants it.
3. Run the setup script from this skill directory:

```bash
python3 <skill-dir>/scripts/init-execplans.py --repo-root <repo-root> --plan-path <chosen-plan-path>
```

4. If the user wants a starter feature plan as well, create one with:

```bash
python3 <skill-dir>/scripts/init-execplans.py --repo-root <repo-root> --plan-path <chosen-plan-path> --example-plan plans/<slug>.md
```

5. Review the resulting `AGENTS.md`, `PLANS.md`, and any starter ExecPlan. Adjust wording only where the repo needs a different path convention or terminology.
6. Validate the setup with:

```bash
python3 <skill-dir>/scripts/validate-execplans.py --repo-root <repo-root> --plan-path <chosen-plan-path>
```

Add `--execplan <path>` if you also created a starter ExecPlan file.

## Setup Rules

- Preserve existing repo conventions when they are already coherent.
- Do not overwrite an existing `PLANS.md` or ExecPlan file unless the user explicitly asks.
- Keep `AGENTS.md` concise. It only needs enough guidance to tell agents when to use an ExecPlan and where the shared `PLANS.md` lives.
- Keep `PLANS.md` as the source of truth for the ExecPlan standard.
- Default to repository-root `PLANS.md` unless there is an existing reason not to.

## What Good Setup Looks Like

At minimum, the repository ends with:

- an `AGENTS.md` entry that tells agents to use ExecPlans for complex features and points at the shared `PLANS.md`
- a `PLANS.md` file that explains the ExecPlan standard, living-document behavior, required sections, and formatting rules
- optionally, a starter ExecPlan document for a specific task

## Local Defaults

This skill adopts the official OpenAI cookbook ideas, but makes two pragmatic local choices:

- It defaults to `PLANS.md` at the repo root instead of `.agent/PLANS.md` unless the repo already uses `.agent/`.
- It ships a starter ExecPlan template in `assets/EXECPLAN.template.md` so a user can immediately create the first concrete plan after setup.

## References

- Read [references/execplan-rules.md](./references/execplan-rules.md) for the distilled rules from the official cookbook article and the local path-choice guidance.

## Resources

### scripts/

- `scripts/init-execplans.py`: create or update `AGENTS.md`, create `PLANS.md` from the bundled template, and optionally create a starter ExecPlan file.
- `scripts/validate-execplans.py`: verify the setup files exist and contain the required ExecPlan sections.

### assets/

- `assets/PLANS.md.template`: shared ExecPlan rules document derived from the official OpenAI guidance.
- `assets/EXECPLAN.template.md`: starter per-task ExecPlan template that points back to the shared `PLANS.md`.

### references/

- `references/execplan-rules.md`: concise summary of the official cookbook guidance and the local conventions used by this skill.
