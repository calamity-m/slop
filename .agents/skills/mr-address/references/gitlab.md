# GitLab MR Operations

Use this reference after the workflow identifies the target review as a GitLab merge request. Keep the checkpoint updated with command outputs that affect the next step.

## Required Identifiers

Collect these before acting:

- Project path or numeric project ID.
- MR IID.
- Source branch, target branch, and current head SHA.
- Latest pipeline ID.
- Failed job IDs and names.
- Discussion IDs and note IDs for replies and resolution.

URL-encode project paths for API calls, for example `group/subgroup/project` becomes `group%2Fsubgroup%2Fproject`.

## Read MR Context

```bash
glab mr view <mr> --output json
glab mr diff <mr>
glab mr view <mr> --comments --unresolved
```

Read linked issues from the MR description, system notes, and explicit URLs in discussion bodies.

## Check Failed Pipelines And Jobs

Start from the MR branch or latest MR pipeline. Prefer JSON/API output when scripting.

```bash
glab pipeline list --branch <source-branch>
glab pipeline status
glab ci view --pipeline-id <pipeline-id>
```

For API-driven inspection:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/pipelines"
glab api "projects/<project_id>/pipelines/<pipeline_id>/jobs?per_page=100"
```

Treat jobs with `status` of `failed` as actionable. Record `pending`, `running`, `canceled`, and `skipped` separately in the checkpoint.

Fetch failed job logs:

```bash
glab ci trace <job-id> --pipeline-id <pipeline-id>
glab api "projects/<project_id>/jobs/<job_id>/trace"
```

Capture the failing excerpt and correlate it with the MR diff before editing.

## Discussions And Threads

List discussions first with the CLI:

```bash
glab mr note list <mr> --state unresolved -F json
glab mr note list <mr> --type diff --state unresolved -F json
glab mr note list <mr> --file <path> -F json
```

Fetch discussions through the API when you need raw fields not shown by the CLI:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/discussions?per_page=100"
```

Useful summary shape:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/discussions?per_page=100" \
  | jq '.[] | {id, resolved: .notes[0].resolved, file: .notes[0].position.new_path, line: .notes[0].position.new_line, body: .notes[0].body}'
```

Group discussions by file, line, and concern. Record each discussion ID and decision in the checkpoint.

## Reply To Discussions

For multiline replies or text containing backticks, `$`, `!`, or other shell-sensitive characters, write the body to a file with a single-quoted heredoc first:

```bash
cat > "$BODY_FILE" << 'BODYEOF'
Addressed in <commit-sha>. The change ...
BODYEOF
```

Reply to the existing discussion rather than posting a detached MR note. Prefer the CLI when available:

```bash
glab mr note create <mr> --reply <discussion-id-or-prefix> -m "$(cat "$BODY_FILE")"
```

`--reply` accepts a full discussion ID or a unique prefix of at least 8 characters.

Use the API fallback when the CLI cannot address the discussion shape:

```bash
glab api \
  --method POST \
  "projects/<project_id>/merge_requests/<mr_iid>/discussions/<discussion_id>/notes" \
  -f "body=$(cat "$BODY_FILE")"
```

Use a general MR note only when the reply is not tied to a specific discussion:

```bash
glab mr note create <mr> -m "$(cat "$BODY_FILE")"
```

## Resolve Discussions

Resolve only discussions that are actually addressed:

```bash
glab mr note resolve <mr> <discussion-id-or-note-id>
```

The identifier can be a full discussion ID, a unique 8+ character discussion ID prefix, or an integer note ID. Use the API fallback only if the CLI cannot resolve the discussion:

```bash
glab api \
  --method PUT \
  "projects/<project_id>/merge_requests/<mr_iid>/discussions/<discussion_id>" \
  -f resolved=true
```

If a discussion was already resolved or made outdated by later commits, record that in the checkpoint rather than replying again.

## Critical Gotchas

- `glab mr note list -F json` is the first choice for discussion IDs; API discussion JSON is the fallback when the CLI omits required fields.
- Discussion replies need `glab mr note create --reply` or the discussion endpoint; a general MR note loses thread context.
- Nested JSON for inline comments is fragile with `-f`; use JSON input when creating new inline notes. Addressing existing feedback normally needs discussion replies, not new inline notes.
- Always re-read pipeline state after pushing because new commits create new pipeline IDs and job IDs.
- Use file-backed bodies for any comment that includes shell-sensitive characters.
