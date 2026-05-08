# GitLab MR Review

Use this reference after the workflow identifies the target review as a GitLab merge request.

## Required Identifiers

Collect these before posting comments:

- Project path or numeric project ID.
- MR IID.
- Source branch, target branch, and MR head SHA.
- Diff refs: `base_sha`, `start_sha`, and `head_sha`.
- Changed file paths and target line numbers.
- Discussion IDs for existing threads.

URL-encode project paths for API calls, for example `group/subgroup/project` becomes `group%2Fsubgroup%2Fproject`.

## Read MR Context Before Diff

Read title, description, linked issue text, and review state before fetching the diff:

```bash
glab mr view <mr> --output json
glab mr view <mr> --comments --unresolved
```

Fetch discussions through the CLI first:

```bash
glab mr note list <mr> --state unresolved -F json
glab mr note list <mr> --type diff --state unresolved -F json
```

Use the API when you need raw fields not shown by the CLI:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/discussions?per_page=100"
```

Record unresolved concerns before opening the diff.

## Review Repository Guidance Before Diff

Look for local standards and architecture notes that govern changed areas:

```bash
find . -maxdepth 3 \( \
  -iname 'AGENTS.md' -o \
  -iname 'CONTRIBUTING.md' -o \
  -iname 'README.md' -o \
  -iname 'ARCHITECTURE.md' -o \
  -iname 'ADR*.md' \
\) -print
```

Also inspect nearby README or docs under changed directories after you know the changed file list.

## Read Diff And Changed Branch Code

Fetch the changed file list and full patch:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>/changes" \
  | jq '.changes[].new_path'
glab mr diff <mr>
```

Confirm local branch state before inspecting files:

```bash
git status --short
git branch --show-current
git rev-parse --short HEAD
```

Inspect the current branch files directly for the code-quality pass. Use the diff to locate changed areas, but judge the final branch code.

## Read Existing Base Code

Compare the current branch with base-branch precedent without changing the worktree:

```bash
git fetch origin <target-branch>
git show origin/<target-branch>:<path>
git diff origin/<target-branch>...HEAD -- <path>
```

For broader exploration, create a temporary worktree outside the repository:

```bash
git worktree add /tmp/mr-review/base-<review-id> origin/<target-branch>
```

Remove temporary worktrees only when the review is finished and the user has not asked to keep artifacts.

## Line Discussions

Fetch diff refs before creating line discussions:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>" \
  | jq '.diff_refs'
```

Create a changed-line discussion with the GitLab discussions API:

```bash
glab api \
  --method POST \
  "projects/<project_id>/merge_requests/<mr_iid>/discussions" \
  -f "body=$(cat "$BODY_FILE")" \
  -f "position[position_type]=text" \
  -f "position[base_sha]=<base_sha>" \
  -f "position[start_sha]=<start_sha>" \
  -f "position[head_sha]=<head_sha>" \
  -f "position[old_path]=<old_path>" \
  -f "position[new_path]=<new_path>" \
  -F "position[new_line]=<line>"
```

Use `old_line` for removed lines. Use both `old_line` and `new_line` for unchanged lines shown in the diff. If nested form encoding behaves inconsistently in the local `glab` version, use JSON input instead of repeated `-f` fields.

Use a detached MR note only for review-request-level concerns:

```bash
glab mr note create <mr> -m "$(cat "$BODY_FILE")"
```

## Critical Gotchas

- General MR notes are not line-level discussions. Use the discussions API for code findings.
- Inline discussion positions must match the MR diff refs. Re-fetch diff refs after force-pushes or rebases.
- `glab mr note list -F json` is the first choice for discussion IDs; API discussion JSON is the fallback when the CLI omits required fields.
- Do not comment on every observation from the record; post only confirmed actionable findings.
