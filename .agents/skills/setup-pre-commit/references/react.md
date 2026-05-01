# React hooks

## Detection

Files matching `**/*.tsx` or `**/*.jsx`, or presence of `react` in `package.json` dependencies, or config files like `vite.config.*`, `next.config.*`.

## Hooks

Same base as TypeScript, with React-aware ESLint rules:

```toml
# Prettier — formatting (covers tsx/jsx too)
[[repos]]
repo = "https://github.com/pre-commit/mirrors-prettier"
rev = "<latest-tag>"
hooks = [
    { id = "prettier", types_or = ["ts", "tsx", "js", "jsx", "json", "yaml", "markdown", "css"] },
]

# ESLint — linting with React plugin
[[repos]]
repo = "https://github.com/pre-commit/mirrors-eslint"
rev = "<latest-tag>"
hooks = [
    { id = "eslint", files = "\\.(tsx?|jsx?)$", args = ["--fix", "--max-warnings=0"] },
]
```

## Notes

- The ESLint hook relies on the project's own ESLint config to load React-specific rules (`eslint-plugin-react`, `eslint-plugin-react-hooks`, `eslint-plugin-jsx-a11y`). Confirm those plugins are installed in the project before adding the hook.
- If the project uses Next.js, it likely already configures ESLint via `next lint` — check `eslint.config.*` or `.eslintrc.*` before assuming rules are in place.
- `types_or` in prettier covers `.tsx`/`.jsx` via the `ts`/`js` type matchers — no extra config needed.
## Alternatives to Prettier + ESLint

Pick one toolchain — don't mix them.

**Biome** (all-in-one formatter + linter, Node-based):

```toml
[[repos]]
repo = "https://github.com/biomejs/pre-commit"
rev = "<latest-tag>"
hooks = [{ id = "biome-check", args = ["--write"] }]
```

**oxfmt + oxlint** (Rust-based, no Node required for the hooks themselves):

```toml
[[repos]]
repo = "https://github.com/oxc-project/oxc"
rev = "<latest-tag>"
hooks = [{ id = "oxfmt" }]

[[repos]]
repo = "https://github.com/oxc-project/oxc"
rev = "<latest-tag>"
hooks = [{ id = "oxlint" }]
```

oxlint does not yet cover all ESLint rules, including some React-specific ones (`react-hooks/rules-of-hooks`, `jsx-a11y/*`). Check coverage before switching — you may need to keep a minimal ESLint config for rules oxlint doesn't handle yet.
