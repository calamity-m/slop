# README Examples

## Good: Concise and Useful

```markdown
# sqlq

A CLI tool that runs SQL queries against CSV and JSON files. Pipe data in, get results out.

## Quick Start

Requires Go 1.21+.

1. `go install github.com/example/sqlq@latest`
2. `echo "name,age\nAlice,30\nBob,25" | sqlq "SELECT name FROM stdin WHERE age > 27"`

Output: `Alice`

## Why

Sometimes you need to filter structured data and `jq`/`awk` isn't expressive enough. sqlq lets you use SQL you already know against files you already have, without loading anything into a database.
```

**Why this works:** You know what it does, you can run it in 30 seconds, and you understand when to reach for it. Done.

---

## Bad: The Kitchen Sink

```markdown
# sqlq

[![Build Status](https://img.shields.io/...)](...)
[![Coverage](https://img.shields.io/...)](...)
[![Go Report Card](https://img.shields.io/...)](...)
[![License](https://img.shields.io/...)](...)
[![Downloads](https://img.shields.io/...)](...)

> A blazing-fast, enterprise-grade SQL query engine for structured data files.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

## Features

| Feature | Status |
|---------|--------|
| CSV support | ✅ |
| JSON support | ✅ |
| Parquet support | 🚧 |
| XML support | 📋 |
| YAML support | 📋 |

## Installation

### macOS

Using Homebrew:
...

### Linux

Using apt:
...
Using yum:
...
Using snap:
...

### Windows

Using Chocolatey:
...
Using Scoop:
...

### From source

...

## Contributing

Please read CONTRIBUTING.md...

## Code of Conduct

Please read CODE_OF_CONDUCT.md...

## License

MIT — see LICENSE file.
```

**Why this fails:** Five badges, a TOC (meaning the README is too long), a feature table with roadmap items that don't exist yet, six install paths when one would do, and three sections that just point to files that already exist in the repo. The reader still doesn't know *why* they'd use this over alternatives.

---

## Good: "Why" Section That Earns Attention

```markdown
## Why

We tried Terraform, Pulumi, and raw CloudFormation. Terraform's state management
was a constant source of incidents. Pulumi required the team to learn a new SDK.
CloudFormation was verbose but at least declarative and stateless.

stacksmith is a thin wrapper around CloudFormation that adds: parameterized
templates (without Jinja), dry-run diffs, and multi-account targeting. Nothing else.
```

**Why this works:** It tells you the landscape, what was tried, why those didn't work, and exactly what this tool adds. No marketing. You can decide in 15 seconds if this is relevant to you.

---

## Bad: "Why" That Says Nothing

```markdown
## Why sqlq?

sqlq is designed to be fast, flexible, and easy to use. It leverages the power of
SQL to provide a familiar interface for data manipulation. Whether you're a data
engineer, backend developer, or DevOps professional, sqlq fits seamlessly into
your workflow.
```

**Why this fails:** Pure marketing. Describes no actual capability, no tradeoff, no decision. Could describe literally any tool.
