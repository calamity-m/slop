# TypeScript hooks

## Detection

Files matching `**/*.ts` or presence of `tsconfig.json`. No `vite`, `next.config.*`, or JSX files that would indicate React — use `react.md` instead for those projects.

## Hooks

```toml
# Prettier — formatting
[[repos]]
repo = "https://github.com/pre-commit/mirrors-prettier"
rev = "<latest-tag>"
hooks = [{ id = "prettier", types_or = ["ts", "json", "yaml", "markdown"] }]

# ESLint — linting
[[repos]]
repo = "https://github.com/pre-commit/mirrors-eslint"
rev = "<latest-tag>"
hooks = [
    { id = "eslint", files = "\\.ts$", args = ["--fix", "--max-warnings=0"] },
]
```

## Notes

- `prettier` and `eslint` both require the project to have their config files (`prettier.config.*`, `.eslintrc.*` or `eslint.config.*`) already set up. If they're missing, write minimal configs before adding the hooks.
- `--max-warnings=0` makes ESLint fail on any warning. Adjust if the project has existing warnings to clean up first.
- `mirrors-prettier` and `mirrors-eslint` both require node/npm to be available for hook environment setup.

## Alternatives to Prettier + ESLint

Pick one toolchain — don't mix them.

**Biome** (all-in-one formatter + linter, Node-based):

```toml
[[repos]]
repo = "https://github.com/biomejs/pre-commit"
rev = "<latest-tag>"
hooks = [{ id = "biome-check", args = ["--write"] }]
```

**oxfmt + oxlint** (Rust-based, faster cold starts, no Node required for the hooks themselves):

```toml
# oxfmt — formatter
[[repos]]
repo = "https://github.com/oxc-project/oxc"
rev = "<latest-tag>"
hooks = [{ id = "oxfmt" }]

# oxlint — linter (optional, pairs well with oxfmt)
[[repos]]
repo = "https://github.com/oxc-project/oxc"
rev = "<latest-tag>"
hooks = [{ id = "oxlint" }]
```

Use oxfmt/oxlint when the project is already in the oxc ecosystem or when hook speed is a priority (Rust binary, no environment setup). Note that oxlint does not yet cover every ESLint rule — check coverage against the project's existing lint config before switching.
