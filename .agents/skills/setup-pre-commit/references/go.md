# Go hooks

## Detection

Files matching `**/*.go` or presence of `go.mod`.

## Hooks

```toml
[[repos]]
repo = "local"

[[repos.hooks]]
id = "go-fmt"
name = "go fmt"
entry = "gofmt -l -w"
language = "system"
types = ["go"]

[[repos.hooks]]
id = "go-vet"
name = "go vet"
entry = "go vet ./..."
language = "system"
pass_filenames = false
always_run = true

[[repos.hooks]]
id = "go-build"
name = "go build"
entry = "go build ./..."
language = "system"
pass_filenames = false
always_run = true
```

## Optional: golangci-lint

If the project already has a `.golangci.yml`, add:

```toml
[[repos.hooks]]
id = "golangci-lint"
name = "golangci-lint"
entry = "golangci-lint run"
language = "system"
pass_filenames = false
always_run = true
```

## Notes

- All hooks require a working Go toolchain on PATH. `golangci-lint` must also be installed separately.
- `go build` catches compile errors before commit — fail fast, negligible overhead on small codebases.
- Skip `golangci-lint` if there's no existing config — it's opinionated and slow to tune from scratch; better left to CI until the project has settled lint rules.
