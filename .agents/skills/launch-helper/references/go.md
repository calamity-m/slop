# Go Launch Configs

## Detection

Treat the repo as Go when `go.mod` exists or Go files are the requested target. Inspect:

- `go.mod` module path and `go` version
- `cmd/*/main.go`, root `main.go`, and package layout
- Existing `go test` or `make` targets

## Patterns

Debug the current package when there is no obvious app entrypoint:

```jsonc
{
  "name": "Debug Go package",
  "type": "go",
  "request": "launch",
  "mode": "debug",
  "program": "${workspaceFolder}"
}
```

Debug a command under `cmd/<name>` when that is the app entrypoint:

```jsonc
{
  "name": "Debug Go command",
  "type": "go",
  "request": "launch",
  "mode": "debug",
  "program": "${workspaceFolder}/cmd/<name>"
}
```

Debug tests for the current package:

```jsonc
{
  "name": "Debug Go tests",
  "type": "go",
  "request": "launch",
  "mode": "test",
  "program": "${fileDirname}"
}
```

## Notes

- Use `"args"` only when the repo documents required CLI arguments.
- Use `"envFile"` only if the repo already has a committed env example or the user asked for it.
- Verify with `go test ./...` when practical.
