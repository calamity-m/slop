---
name: read-me
description: "Generate or rewrite a repository's README.md around three pillars: what it is, how to run it, and why it matters. Ruthlessly cuts filler, badges, verbose tables, and anything that belongs in separate docs. Use this skill when the user asks to create, improve, rewrite, or clean up a README."
---

# Read Me

Generate or rewrite a repository README so that a new reader can answer three questions in under sixty seconds:

1. **What the fuck is this thing?**
2. **How the fuck do I run it?**
3. **Why the fuck do I care about it?**

Everything else is noise. If content doesn't serve one of those three questions, it either gets cut or linked out to a separate doc.

## Workflow

1. **Explore the repo.** Read the project root, package manifests, entrypoints, config files, and any existing README. Understand what the project actually does — not what it aspires to do.
2. **Identify the three answers.** Draft one clear answer for each pillar based on what the code actually shows.
3. **Check for an existing README.**
   - If one exists: rewrite it around the three pillars. Do not preserve sections that don't serve them. If you are dropping significant content, tell the user what was cut and why.
   - If none exists: generate a new one from scratch.
4. **Write the README.** Follow the structure and rules below.
5. **Show the user the result** and mention anything you cut or couldn't determine from the codebase (e.g., if you had to guess at setup steps).

## README Structure

The README follows this skeleton. Every section is short. No section is optional unless marked.

```markdown
# Project Name

One to three sentences. What this thing is and what problem it solves. No mission statements, no marketing. A developer should read this and immediately know whether this repo is relevant to them.

## Quick Start

The fastest path from `git clone` to seeing it work. Numbered steps. Include actual commands. If there are prerequisites (runtime, env vars, credentials), list them first — briefly.

## Why

One short paragraph or a few bullet points. What's the value proposition? Why does this exist instead of using $ALTERNATIVE? What's the core design decision? This section earns the reader's attention — don't waste it.

## Further Reading _(optional)_

A short list of links to deeper docs, architecture decisions, API references, or contributing guides. Only include if those docs actually exist in the repo or are hosted somewhere. Do not create placeholder links.
```

## Rules

### Content Rules

- **No badges.** They add visual noise and zero information a developer can't get from the repo itself.
- **No feature lists.** If the "What" section is clear, features are self-evident. Long feature tables are documentation, not a README.
- **No verbose install matrices.** If the project runs on multiple platforms, pick the primary one for Quick Start and link to extended install docs if they exist.
- **No license section in the body.** The LICENSE file exists for a reason. A one-line mention at the very bottom is fine if the user asks for it.
- **No auto-generated API docs.** Those belong in `/docs` or a hosted site, not the README.
- **No "Table of Contents".** If your README needs a TOC, it's too long.
- **No screenshots or GIFs unless specifically requested.** They go stale fast and bloat the file.

### Tone Rules

- Write like a human explaining the project to a colleague, not like a marketing page.
- Be direct. Short sentences. Active voice.
- Technical precision over corporate polish.
- If you don't know something (e.g., you can't determine the run command from the codebase), say so plainly rather than guessing wrong.

### Accuracy Rules

- **Every command in Quick Start must be derived from the actual codebase** — package.json scripts, Makefile targets, Dockerfiles, entrypoints. Do not invent commands.
- **Do not describe features the code doesn't have.** Read the code, not the aspirational old README.
- If the repo has no docs to link to, don't include a Further Reading section with empty promises.

## Anti-patterns to Actively Remove

When rewriting an existing README, watch for and eliminate:

- Walls of badges at the top
- "Table of Contents" sections
- Feature comparison tables
- Copy-paste install instructions for every OS/package-manager combination
- "Contributing", "Code of Conduct", "Changelog" sections that duplicate files already in the repo
- Marketing language ("blazing fast", "enterprise-grade", "batteries included")
- Architecture diagrams in the README (link to them instead)
- Redundant "Prerequisites" sections when Quick Start already covers them

## What Gets Linked, Not Inlined

These topics deserve their own docs, not README real estate:

- Architecture and design decisions
- API reference
- Contributing guidelines
- Detailed configuration reference
- Migration guides
- Troubleshooting

If these docs exist, link them from Further Reading. If they don't exist, don't mention them.

For examples of good and bad READMEs, see [references/examples.md](./references/examples.md).
