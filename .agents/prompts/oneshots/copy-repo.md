---
description: Scaffold a brand-new greenfield repository that mirrors the stack, structure, and conventions of an existing repository
argument-hint: "<source-repo-path> [target-path-or-name] [notes]"
---

You are being tasked with creating a new greenfield repository modeled on an existing one:

```text
$ARGUMENTS
```

The first argument is the path to the source repository to learn from. An optional second argument is the target path or name for the new repository. Anything after that is notes from the user about what to keep, drop, or change.

Your goal is to reproduce the **skeleton** of the source repository — its stack, tooling, dependencies, layout, and conventions — as a clean starting point for a new project. You are copying the shape, not the product.

## 1. Survey the source repository

Read the source repository enough to characterize it. Do not read every file; focus on:

- **Manifests and build files**: `pom.xml`, `build.gradle`, `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, lockfiles — languages, frameworks, dependencies, and their versions.
- **Layout**: the directory tree, module/package structure, where source, tests, config, and resources live.
- **Tooling and config**: formatters, linters, `.editorconfig`, CI pipelines, Dockerfiles, compose files, Makefiles/taskfiles, `.gitignore`, editor/agent config.
- **Conventions and patterns**: read a handful of representative source files to identify the architectural idioms in use — e.g. layered packages, named JDBC templates, repository/service separation, error-handling style, test structure and naming.

Summarize for yourself what defines this repo's skeleton before writing anything.

## 2. Decide what transfers

Transfers to the new repo:

- The stack and dependency set, pinned to the **same versions** as the source unless the user's notes say to upgrade.
- The directory and module structure, with domain-specific names replaced by the new project's names.
- Tooling, formatter/linter config, CI skeleton, container setup, `.gitignore`.
- The architectural patterns, demonstrated by **one minimal example per pattern** (e.g. one entity with a named-parameter JDBC repository, one service, one controller, one test of each kind) so the idiom is visible and extendable.

Never transfers:

- Business logic, domain models, and product code beyond the minimal examples.
- Secrets, credentials, `.env` values, real hostnames, or anything from ignored files. Recreate config as placeholders or `*.example` files.
- Git history, licensing, or authorship of the source. Start fresh.

## 3. Resolve the target

If a target path or name was given, use it. Otherwise derive a sensible directory name and create it as a sibling of the current working directory's contents — but if the destination or the new project's identity (name, base package/module path, group id) is genuinely ambiguous, ask the user before writing files. Refuse to write into a non-empty directory unless the user confirms.

## 4. Scaffold

Build the new repository in one pass:

1. Create the directory tree and `git init`.
2. Write the manifests/build files with the transferred dependency set.
3. Write tooling and config files (formatter, linter, CI, Docker, `.gitignore`).
4. Write the minimal wiring so the project runs: entry point, application config with placeholder values, and the one-per-pattern example code identified in step 2.
5. Wire the examples into a working **hello-world slice**: the most MVP, blow-away demonstration of the setup end to end, shaped by what the source repo is. For a REST + database service, that is a hello endpoint that reads through the database layer, backed by a base dummy migration; for a CLI, a hello subcommand; for a web frontend, a hello page rendered through the real routing/build path; combine as appropriate for hybrid repos. It should prove the plumbing works and be trivially deletable once real work starts — name it so that's obvious (`hello`, not something domain-like).
6. Write a short `README.md`: what the stack is, how to build, run, and test (including how to run the hello-world slice), and which repo it was modeled on.

Match the source repository's naming and code style in everything you write.

## 5. Verify

The new repository must actually work, not just look right:

- Run the build (`mvn -q verify`, `gradle build`, `npm install && npm run build`, `go build ./...`, or the stack's equivalent) and fix what fails.
- Run the test suite so the example tests pass.
- Exercise the hello-world slice where practical: hit the endpoint, run the CLI command, or load the page (a dependency like a database may be stood up via the repo's compose file if it has one).
- Run the formatter/linter if one was configured.

If a required toolchain is missing locally, say so explicitly and report exactly which verification steps were skipped.

Finish by reporting: the target path, the stack and key versions, the patterns you carried over with where each example lives, and anything from the source you deliberately left out.
