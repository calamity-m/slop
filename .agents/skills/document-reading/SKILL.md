---
name: document-reading
description: Read docx, pdf, pptx, xlsx, epub, and other non-plain-text documents by converting them to Markdown with markitdown. Use whenever asked to read, summarize, or extract from such a file.
---

# Document Reading

Convert non-plain-text documents to Markdown with [markitdown](https://github.com/microsoft/markitdown), then read the Markdown. Do not try to read binary formats (docx, pdf, pptx, xlsx, epub) directly — convert first.

All scripts live in `scripts/` relative to this skill directory and are self-contained: they use `markitdown` from PATH when installed, otherwise fall back to `uvx --from "markitdown[all]" markitdown` (first uvx run downloads packages; later runs are instant).

## Workflow

1. Verify the tooling once per session:

   ```bash
   scripts/validate-install.sh
   ```

   It prints the runner that will be used, or exits 1 with install hints (`uv tool install "markitdown[all]"` is the preferred persistent install).

2. Convert a single document:

   ```bash
   scripts/convert.sh report.docx                # Markdown to stdout
   scripts/convert.sh report.pdf /tmp/report.md  # Markdown to a file
   ```

   Extra arguments after the input/output are passed through to markitdown, e.g. `scripts/convert.sh weird-name.bin -x .docx` to hint the real format, or `--keep-data-uris` to preserve embedded base64 images (truncated by default).

3. Convert a directory of documents:

   ```bash
   scripts/convert-batch.sh ./docs /tmp/docs-md          # default extensions
   scripts/convert-batch.sh ./docs /tmp/docs-md pdf docx # only these
   ```

   Failures are reported and skipped; the script exits 1 at the end if any file failed.

4. Read the resulting Markdown. For large documents, convert to a file in a scratch directory and read it selectively (search for headings or keywords) instead of streaming the whole output into context.

## Format Notes

- **pdf**: Text extraction only — a scanned/image-only PDF converts to empty or near-empty Markdown. If that happens, say so; markitdown does not OCR. (Azure Document Intelligence via `-d -e <endpoint>` is the escape hatch if the user has an endpoint.)
- **xlsx/xls**: Each sheet becomes a section with a Markdown table. Formulas are converted to their computed values.
- **pptx**: Slide text, notes, and table content; embedded charts come through as data where possible.
- **docx**: Headings, lists, and tables map cleanly to Markdown. Tracked changes are not resolved — accept/reject state is whatever the file stores.
- **zip**: Contents are extracted and each supported file inside is converted, concatenated into one output.
- **images**: Only EXIF metadata (and OCR only via optional LLM integration, not configured here) — do not expect image *content* as text.
- **Anything odd**: If a file has a wrong or missing extension, pass `-x .<real-ext>` so markitdown picks the right converter.

## When Not to Use

Plain text formats (md, txt, json, yaml, source code) — read those directly. HTML is borderline: read it directly when you need the markup, convert it when you need the readable text.
