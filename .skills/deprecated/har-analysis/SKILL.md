---
name: har-analysis
description: Analyze HAR (HTTP Archive) network captures to debug API requests, diagnose performance, and reverse-engineer how a web app talks to its backend (pagination, lazy loading, auth flows). Use whenever the user provides a .har file or asks to inspect browser network traffic, failed requests, slow endpoints, or API call patterns from a capture — even if they don't say "HAR".
disable-model-invocation: true
---

# HAR Analysis

Answer questions about a HAR capture — failed requests, slow endpoints, payloads, and how the app's API actually behaves — without drowning your context in raw JSON.

## Never read the .har file directly

HAR files are frequently tens of megabytes, and even small ones bury the signal (headers, timings, bodies) in noise. Always go through the bundled query tool:

```bash
python3 scripts/har.py <subcommand> <file.har> [options]
```

Run `python3 scripts/har.py --help` (or `<subcommand> --help`) for full options. Entry indexes are stable across all subcommands, so an index found via `list` or `endpoints` can be passed straight to `show`.

## Workflow

1. **Always start with `summary`** — entry count, capture window, domains, status distribution, and the indexes of any error responses. This tells you which follow-up view matters.
2. Pick the view that matches the question:

| Question                            | Command                                                                   |
| ----------------------------------- | ------------------------------------------------------------------------- |
| What failed?                        | `list --status 4xx` / `--status 5xx`, then `show INDEX --response-body`   |
| Why is it slow?                     | `timing`, and `list --sort size` for payload weight                       |
| What does endpoint X return/accept? | `list --url-contains X`, then `show INDEX --request-body --response-body` |
| How does the API work overall?      | `endpoints` (add `--domain` to focus on the first-party API)              |

3. **Drill into single entries with `show`**. Bodies are omitted by default and truncated at 4000 bytes — raise `--max-bytes` only when you actually need more, and note that response bodies may be base64-encoded (the tool labels this).

## Reverse-engineering API behavior

The `endpoints` command is the main instrument: it groups API calls by method + URL template (numeric IDs and UUIDs collapse to `{id}`), skips static assets, and reports each query parameter as `[fixed]` or `[varies]` with its observed values. Read it like this:

- **Pagination style**: a varying `page`/`offset` param means page/offset pagination; a varying `cursor`/`next`/`after` param (often base64) means cursor pagination. Confirm by `show`ing the first response body — look for `total_pages`, `next_cursor`, or a `Link` response header.
- **Lazy loading / infinite scroll**: repeated calls to the same template whose `startedDateTime` values (visible via `show`) are spread out over the capture, rather than clustered at page load, were triggered by user interaction. Compare against the initial document request's timestamp.
- **N+1 patterns**: a template like `GET /api/items/{id}` with many calls right after a list call suggests the client fetches details per row.
- **Auth flow**: `show` an API entry's request headers for `Authorization`/cookies, and `list --url-contains token` or `--url-contains auth` to find where credentials are obtained or refreshed.

When reporting reverse-engineered behavior, cite entry indexes as evidence (e.g. "cursor pagination — entries 10–13 pass `cursor`, each response carries `next_cursor`") so the user can verify.

## Performance analysis

`timing` shows the slowest entries with per-phase breakdown. Interpret phases:

- high `wait` = server think time (backend slowness), the most common culprit for API calls;
- high `blocked` = connection-pool queueing, often from too many parallel requests to one host;
- high `dns`/`connect`/`ssl` = first contact with a domain — expected once per host, a problem if repeated;
- high `receive` = large payload or slow network; cross-check with `list --sort size`.

Also check `summary` for third-party domains adding weight, and 304s/cache headers (`show`) when the question is about caching.

## Reporting results

Lead with the direct answer to the user's question, backed by concrete numbers (status codes, ms, sizes) and entry indexes. Don't paste large command outputs or bodies into the reply — quote only the lines that carry the finding.
