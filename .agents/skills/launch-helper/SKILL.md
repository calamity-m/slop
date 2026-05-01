---
name: launch-helper
description: Create or update VS Code .vscode/launch.json debug configurations for application projects. Use when Codex is asked to set up, repair, extend, or explain VS Code launch/debug configs for Go, Python, Rust, JavaScript/TypeScript including Vite and other builders, or Java projects including projects that need a specific installed JDK selected from repository metadata.
---

# Launch Helper

Use this skill to produce a small, working `.vscode/launch.json` that matches the repository instead of a generic template.

## Workflow

1. Inspect the project shape before editing:
   - Existing `.vscode/launch.json`, `.vscode/settings.json`, and `.vscode/tasks.json`
   - Language markers: `go.mod`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `package.json`, `tsconfig.json`, `vite.config.*`, `pom.xml`, `build.gradle*`, `.java-version`, `.sdkmanrc`, `mise.toml`
   - Existing run commands in scripts, Makefiles, README snippets, or task config
2. Pick the smallest config that debugs the main local workflow. Avoid adding compound configs, tasks, env files, browser configs, or framework-specific extras unless the repo needs them.
3. Read only the relevant reference files:
   - Go: `references/go.md`
   - Python: `references/python.md`
   - Rust: `references/rust.md`
   - JavaScript/TypeScript: `references/javascript-typescript.md`
   - Java and JDK selection: `references/java.md`
4. Preserve unrelated existing launch configs. Add or modify only the entries needed for the request.
5. Validate:
   - Parse JSON with comments using a VS Code-compatible check when available, or at minimum avoid trailing/comma/comment mistakes in generated JSON.
   - Run a cheap language-specific verification command when practical: `go test ./...`, `python -m py_compile`, `cargo test --no-run`, `npm run build`, `mvn test -DskipTests`, or `./gradlew testClasses`.

## Editing Rules

- Use `.vscode/launch.json` version `"0.2.0"`.
- Prefer `${workspaceFolder}` paths and repo-local commands.
- Keep names explicit, such as `Debug Go package`, `Debug Python module`, `Debug Rust binary`, `Debug Vite app`, or `Debug Java main`.
- If a preLaunch task is required, create or update `.vscode/tasks.json` only for that task. Do not invent build tasks if the debugger can launch directly.
- Do not overwrite user-specific paths silently. If a path is machine-specific, prefer `${env:VAR}` or place tool/runtime mapping in `.vscode/settings.json` only when the repo already commits editor settings or the user asked for it.
- For Java projects with multiple possible JDKs, select from repository metadata first, then installed runtimes. Document the chosen JDK source in the final answer.

## Output Shape

When finishing, report:

- Files changed
- Which language/project type was detected
- Which launch configuration names were added or changed
- Any assumptions, especially selected Java JDK version/path or required VS Code extensions
- Verification command and result, or why it was not run
