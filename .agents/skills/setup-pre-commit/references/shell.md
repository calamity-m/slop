# Shell hooks

## Detection

Files matching `**/*.sh`, or scripts with a `#!/bin/bash` / `#!/bin/sh` shebang.

## Hooks

```toml
[[repos]]
repo = "local"

[[repos.hooks]]
id = "shellcheck"
name = "shellcheck"
entry = "shellcheck"
language = "system"
types = ["shell"]
```

## Notes

- Requires `shellcheck` on PATH. Install via your system package manager (`apt install shellcheck`, `brew install shellcheck`, etc.).
- By default the hook runs on files with a shell type (detected by shebang or extension). If the repo has shell scripts without an extension and no shebang, add `files = "\\.sh$"` to restrict to extension only.
- shellcheck respects inline `# shellcheck disable=SCxxxx` directives — use those for intentional deviations rather than weakening the hook config.
