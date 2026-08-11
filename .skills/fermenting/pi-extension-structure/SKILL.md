---
name: pi-extension-structure
description: Structure, create, or reorganize standalone Pi extension packages according to Calam's conventions. Use when building, refactoring, reviewing, or publishing a Pi extension and deciding where entrypoints, source, tests, package metadata, and documentation belong.
---

# Pi Extension Structure

Build boring, source-distributed TypeScript packages with a thin Pi-facing entrypoint, one clear registration path, testable implementation modules, and explicit package metadata. Scale the layout to the feature; do not turn a small extension into a framework.

## Establish the Current Baseline

Before implementing:

1. Read the installed Pi `docs/extensions.md` and `docs/packages.md` completely. Follow the feature-specific docs and examples relevant to the change, such as `docs/tui.md` for custom UI.
2. Inspect `~/code/pi-bwubblewap/` as the fullest local example, then inspect the closest small `~/code/pi-*` repository for the appropriate amount of structure.
3. Treat Pi's installed docs as the API source of truth and local repositories as style examples. Do not copy stale API calls or dependency versions blindly.
4. State any meaningful departure from the layout below before making it.

## Choose the Smallest Honest Layout

A tiny, independent extension may remain one file under `extensions/`. Once behavior needs helpers, configuration, or meaningful tests, prefer:

```text
pi-example/
├── extensions/
│   └── index.ts
├── src/
│   ├── register.ts          # or a narrowly named central registration module
│   ├── config.ts            # only when configuration exists
│   └── <domain>/            # only when a real domain boundary exists
├── tests/
│   ├── <module>.test.ts
│   └── <feature>.integration.test.ts
├── scripts/                 # only for real development/package tasks
├── package.json
├── package-lock.json
├── tsconfig.json
├── README.md
└── LICENSE
```

Ship TypeScript source directly; Pi loads it through jiti. Do not add a build directory or bundler unless distribution actually requires one.

## Keep Boundaries Clear

- Keep `extensions/index.ts` intentionally thin: import `ExtensionAPI`, delegate to the central registration function, and default-export the Pi factory.
- Keep registration and lifecycle flow in one central module. It should make commands, tools, flags, and event wiring easy to audit in one place.
- Extract narrow nearby helpers for configuration, policy, execution, rendering, or protocol details. Prefer pure helpers that can be tested without booting Pi.
- Group by domain only after flat `src/*.ts` files stop being clear. Do not create barrels, service layers, or one-file-per-event abstractions by default.
- Put complex TUI components in their own module; keep simple render functions beside the feature they render.
- Document exported registration functions and reusable APIs with concise TSDoc. Internal comments explain constraints and safety decisions, not syntax.

## Package It Explicitly

In `package.json`:

- Use `"type": "module"`, the `pi-package` keyword, an explicit `pi.extensions` entry, and a restrictive `files` allowlist.
- Keep the lockfile tracked.
- Put third-party runtime libraries in `dependencies`.
- Put Pi-provided imports (`@earendil-works/pi-*` and `typebox`) in `peerDependencies` with `"*"`; pin matching concrete versions in `devDependencies` for local checks.
- Declare the supported Node version when runtime behavior depends on it.
- Prefer scripts named `typecheck`, `test`, `lint`, `format`, `format:check`, and `pack:dry-run`. Add integration or benchmark scripts only when they represent a real separate check.

Use a strict no-emit TypeScript configuration with modern ESM/bundler resolution, explicit `.ts` imports, `verbatimModuleSyntax`, and Node types. Include only directories that actually contain TypeScript.

## Respect Pi Runtime Constraints

- Register capabilities in the factory, but start processes, sockets, watchers, and timers at `session_start` or on demand. Clean session resources up idempotently in `session_shutdown`.
- Guard TUI-only behavior with `ctx.mode === "tui"` and other interactive UI with `ctx.hasUI`.
- Honor project trust before reading project-local configuration, and use Pi's exported config-directory helpers rather than hardcoding `.pi`.
- Keep tool schemas strict, use `StringEnum` for string enums, throw to signal tool errors, and keep model-facing output bounded.
- Use Pi's file mutation queue for tools that modify files. Preserve built-in schemas, result details, and rendering contracts when overriding built-in tools.
- Persist branch-sensitive state in session entries or tool-result details rather than relying only on process memory.

## Test and Document the Package

- Use Node's built-in test runner unless the feature genuinely needs another framework.
- Unit-test parsing, configuration, policy, and other pure behavior. Keep OS-, process-, network-, or Pi-lifecycle tests visibly separate as integration tests.
- Keep test-only exports explicit and narrow when dependency injection would add more machinery than value.
- Write the README for a user first: purpose, requirements, installation or local loading, commands/tools, configuration, important safety or platform limits, development checks, and license.

Before finishing, run every applicable check exposed by the package, normally:

```bash
npm run typecheck
npm test
npm run lint
npm run format:check
npm run pack:dry-run
```

Inspect the dry-run tarball list and confirm it contains the entrypoint, runtime source, README, and license—but not tests, local plans, or generated clutter. If a check is intentionally absent, say why instead of adding tooling solely to satisfy this list.
