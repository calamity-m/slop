---
tags:
  - markitdown
  - documents
  - pdf
  - docx
  - markdown
variables:
  document:
    command: rg --files -g "*.{pdf,docx,pptx,xlsx,epub,html,csv}"
  output:
    default: output.md
---

# markitdown

## Install markitdown globally with uv

Installs the CLI with all optional format converters as a persistent uv tool.

```bash
uv tool install "markitdown[all]"
```

## Convert a document to Markdown on stdout

```bash
markitdown <@document>
```

## Convert a document to a Markdown file

```bash
markitdown <@document> -o <@output:?output.md>
```

## Run markitdown without installing

Runs from the uv cache via uvx; the first run downloads packages.

```bash
uvx --from "markitdown[all]" markitdown <@document>
```

## Convert a file with a wrong or missing extension

`-x` hints the real format so the right converter is used.

```bash
markitdown <@document> -x <@extension:?.docx>
```
