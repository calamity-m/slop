# Rust Launch Configs

## Detection

Treat the repo as Rust when `Cargo.toml` exists. Inspect:

- Workspace members and binary targets
- `[[bin]]` sections
- Existing `cargo run`, `cargo test`, or Makefile commands
- Installed VS Code extension expectations: CodeLLDB uses `"type": "lldb"`; C/C++ uses `"type": "cppdbg"`

## Patterns

Prefer CodeLLDB when no existing config indicates otherwise:

```jsonc
{
  "name": "Debug Rust binary",
  "type": "lldb",
  "request": "launch",
  "cargo": {
    "args": ["build", "--bin", "<bin-name>"],
    "filter": {
      "name": "<bin-name>",
      "kind": "bin"
    }
  },
  "args": [],
  "cwd": "${workspaceFolder}"
}
```

For a single-package repo where the default binary is obvious:

```jsonc
{
  "name": "Debug Rust",
  "type": "lldb",
  "request": "launch",
  "cargo": {
    "args": ["build"]
  },
  "args": [],
  "cwd": "${workspaceFolder}"
}
```

Debug tests:

```jsonc
{
  "name": "Debug Rust tests",
  "type": "lldb",
  "request": "launch",
  "cargo": {
    "args": ["test", "--no-run"]
  },
  "args": [],
  "cwd": "${workspaceFolder}"
}
```

## Notes

- If the repo already uses `cppdbg`, extend that style instead of switching extensions.
- Use explicit `--package` for workspaces when the target package is clear.
- Verify with `cargo test --no-run` or `cargo build` when practical.
