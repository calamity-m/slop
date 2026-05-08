# GitLab MR Creation

Use this reference after the workflow identifies the review provider as GitLab.

## Required Identifiers

Collect these before creating the MR:

- Project path or numeric project ID.
- Source branch, target branch, and current head SHA.
- Whether the branch is pushed to a remote.
- MR template path, if present.
- Recent MR IIDs used as style examples.
- Diff refs and file path/line information for each inline discussion.

URL-encode project paths for API calls, for example `group/subgroup/project` becomes `group%2Fsubgroup%2Fproject`.

## Branch And Diff

```bash
git branch --show-current
git remote -v
git symbolic-ref refs/remotes/origin/HEAD --short
git status --short
git log --oneline <target>..HEAD
git diff --stat <target>...HEAD
git diff <target>...HEAD
```

If the branch is not pushed, push it before creating the MR:

```bash
git push -u origin <source-branch>
```

## Templates

Check common GitLab MR template locations:

```bash
find .gitlab .gitlab/merge_request_templates -maxdepth 2 -type f 2>/dev/null
find . -maxdepth 3 \( -path './.gitlab/merge_request_templates/*' -o -path './.gitlab/merge_request_template.md' \) -type f
```

If multiple templates exist, choose the one that best matches the change. Preserve template headings and remove only instructions meant for authors.

## Recent MR Descriptions

Read the last two merged or recent MRs to match local description style:

```bash
glab mr list --merged --per-page 2 --output json
glab mr list --all --per-page 2 --output json
glab mr view <mr> --output json
```

Use these as style and required-section examples, not as content to copy.

## Create The MR

Use a file-backed description when the body is more than a sentence:

```bash
glab mr create \
  --source-branch <source-branch> \
  --target-branch <target-branch> \
  --title "<why-first title>" \
  --description "$(cat "$BODY_FILE")"
```

Use `--draft` when the MR should not be reviewed yet. Add `--push` only when you intentionally want `glab` to push committed changes as part of creation.

After creation, verify the result:

```bash
glab mr view <mr> --output json
```

## Inline Discussions

For top-level context that is not tied to a changed line:

```bash
glab mr note create <mr> -m "$(cat "$BODY_FILE")"
```

For changed-line discussions, use the GitLab discussions API with a `position` hash. Required position fields include `base_sha`, `head_sha`, `start_sha`, `position_type`, `old_path`, and `new_path`. Use `new_line` for added lines, `old_line` for removed lines, and both for unchanged lines shown in the diff.

First fetch diff refs from the MR:

```bash
glab api "projects/<project_id>/merge_requests/<mr_iid>" \
  | jq '.diff_refs'
```

Then create the discussion:

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

Use JSON input instead of repeated `-f` fields if nested form encoding behaves inconsistently in the local `glab` version.

## Critical Gotchas

- `glab mr create --fill` can seed raw commit data, but this skill requires a why-first title and curated body; do not let autofill replace the drafted rationale.
- GitLab MR templates usually live under `.gitlab/merge_request_templates/`; project or group defaults may not be visible locally.
- General MR notes are not line-level discussions. Use the discussions API when a specific changed line needs context.
- Inline discussion positions must match the MR diff refs. Re-fetch diff refs after force-pushes or rebases.
