# Rust hooks

## Detection

Files matching `**/*.rs` or presence of `Cargo.toml`.

## Hooks

Use `repo = "local"` with `language = "system"` to invoke cargo directly — no external hook repo needed.

```toml
[[repos]]
repo = "local"

[[repos.hooks]]
id = "cargo-fmt"
name = "cargo fmt"
entry = "cargo fmt --check"
language = "system"
pass_filenames = false
always_run = true
stages = ["pre-commit"]

[[repos.hooks]]
id = "cargo-build"
name = "cargo build"
entry = "cargo build"
language = "system"
pass_filenames = false
always_run = true
stages = ["pre-commit"]

[[repos.hooks]]
id = "cargo-test"
name = "cargo test"
entry = "cargo test"
language = "system"
pass_filenames = false
always_run = true
stages = ["pre-commit"]

[[repos.hooks]]
id = "cargo-clippy"
name = "cargo clippy (dead_code ignored)"
entry = "cargo clippy -- -D warnings -A dead_code"
language = "system"
pass_filenames = false
always_run = true
stages = ["pre-commit"]

[[repos.hooks]]
id = "cargo-clippy-strict"
name = "cargo clippy strict (push to main)"
entry = "scripts/pre-push-clippy.sh"
language = "system"
pass_filenames = false
always_run = true
stages = ["pre-push"]
```

The `pre-push` hook uses a script that reads the pushed refs from stdin and only runs strict clippy when pushing to `main`:

```bash
#!/usr/bin/env bash
# scripts/pre-push-clippy.sh
# Only run strict clippy (dead_code included) when pushing to main.
set -e

while read -r local_ref local_sha remote_ref remote_sha; do
    if [ "$remote_ref" = "refs/heads/main" ]; then
        cargo clippy -- -D warnings
        exit 0
    fi
done
```

Place the script at `scripts/pre-push-clippy.sh` and make it executable (`chmod +x`).

## Notes

- `dead_code` is allowed on pre-commit to avoid friction during active development, but enforced on push to main. Adjust the branch name in the script if the primary branch is `master` or something else.
- `cargo build` before `cargo test` is redundant but makes the failure message clearer when the build itself is broken.
- `cargo fmt --check` fails without modifying files — the developer runs `cargo fmt` manually to fix. If you'd prefer auto-fix on commit, change the entry to `cargo fmt` (no `--check`).
- All hooks require a working Rust toolchain (`rustup`, `cargo`) on PATH.
