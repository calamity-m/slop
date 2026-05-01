# Java hooks

## Detection

Files matching `**/*.java` or presence of `pom.xml`, `build.gradle`, `build.gradle.kts`.

## Hooks

```toml
# Format with google-java-format
[[repos]]
repo = "https://github.com/pre-commit/mirrors-google-java-format"
rev = "<latest-tag>"
hooks = [
    { id = "google-java-format", args = ["--aosp"] },
]
```

## Notes

- `--aosp` uses the Android Open Source Project style (4-space indent). Drop that arg for standard Google style (2-space indent). Match whichever the project already uses.
- google-java-format requires Java 11+ on PATH.
- If the project uses Checkstyle or Spotless already, skip this hook to avoid conflicting formatting rules — just add `check-merge-conflict` and `detect-private-key` from the built-ins instead.
