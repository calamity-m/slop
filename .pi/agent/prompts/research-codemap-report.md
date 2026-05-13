---
description: Explore a repository codepath or issue and produce a succinct handoff report for a worker agent
argument-hint: "<repository-topic> [known-leads]"
---

You are being tasked with exploring this repository for:

```text
$1
```

Known starting leads from the user, if any:

```text
${@:2}
```

The repository topic may be a variable, concept, codepath, flow, issue, feature, integration point, or any other repository-related topic.

The known leads may be files, directories, symbols, commands, tests, documents, URLs, error messages, or notes the user already believes are relevant. Start from these leads, or at minimum include them in your initial search before broadening outward.

Your goal is not to implement anything. Your goal is to research the repository and distill the best initial context for a stronger worker agent so they can avoid needless file searching, code tracing, and document sourcing.

Write your final report to:

```text
/tmp/research-codemap-report.md
```

Keep the report succinct, concrete, and file-oriented. Prefer verified repository facts over speculation. If something is unclear or absent, say so directly. If the file already exists, overwrite it completely.

Use this structure:

## Report Brief

A 100-foot overview of the findings. For example: the topic is currently undocumented, integrated through specific endpoints, isolated to test config, embedded in a critical component, or not present in the repository.

## Findings

Cover where the topic is used, occurs, referenced, configured, tested, or documented.

Also summarize its current state in the repository, such as:

- strongly embedded
- isolated or cutaway
- test-only
- configuration-only
- critical production path
- partially implemented
- undocumented
- absent or only indirectly implied

## Repository Map

List the files and line ranges a worker agent should inspect first.

Use this format:

```text
Critical Files:
-> path/to/file.ext - Shortest useful description
   -> lines 10-24 - What this block contributes
   -> lines 80-96 - What this block contributes
-> another/path.ext - Shortest useful description
   -> lines 5-12 - What this block contributes
```

Only include files that are actually useful for understanding or changing the topic. Do not include broad dumps of unrelated search results.
