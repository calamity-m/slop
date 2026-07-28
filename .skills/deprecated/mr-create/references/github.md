# GitHub PR Creation

Use this reference after the workflow identifies the review provider as GitHub.

## Required Identifiers

Collect these before creating the PR:

- Repository in `OWNER/REPO` form.
- Source branch, target branch, and current head SHA.
- Whether the branch is pushed to a remote.
- PR template path, if present.
- Recent PR numbers used as style examples.
- File path, side, line, and commit SHA for each inline comment.

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

If the branch is not pushed, push it before creating the PR:

```bash
git push -u origin <source-branch>
```

## Templates

Check common GitHub PR template locations:

```bash
find .github -maxdepth 3 \( -iname 'pull_request_template.md' -o -path '.github/PULL_REQUEST_TEMPLATE/*' \) -print
```

If multiple templates exist, choose the one that best matches the change. Preserve template headings and remove only instructions meant for authors.

## Recent PR Descriptions

Read the last two merged or recent PRs to match local description style:

```bash
gh pr list --state merged --limit 2 --json number,title,body,mergedAt,url
gh pr list --state all --limit 2 --json number,title,body,state,createdAt,url
```

Use these as style and required-section examples, not as content to copy.

## Create The PR

Use a file-backed body:

```bash
gh pr create \
  --base <target-branch> \
  --head <source-branch> \
  --title "<why-first title>" \
  --body-file <body-file>
```

Use `--draft` when the PR should not be reviewed yet.

After creation, verify the result:

```bash
gh pr view <pr> --json number,title,body,url,headRefName,baseRefName,isDraft
```

## Inline Comments

For top-level context that is not tied to a changed line:

```bash
gh pr comment <pr> --body-file <body-file>
```

For changed-line comments, use the pull request review comments API. Required fields include `body`, `commit_id`, `path`, `line`, and `side`; use `start_line` and `start_side` for a multi-line comment.

```bash
gh api \
  --method POST \
  repos/<owner>/<repo>/pulls/<pr>/comments \
  -f body="$(cat "$BODY_FILE")" \
  -f commit_id=<head-sha> \
  -f path=<path> \
  -F line=<line> \
  -f side=RIGHT
```

Use `side=LEFT` for removed lines. If line placement is fragile, create the PR first, fetch the diff context, and then post the comment.

## Critical Gotchas

- `gh pr create --fill` can be useful for raw commit data, but this skill requires a why-first title and curated body; do not let autofill replace the drafted rationale.
- GitHub PR templates can live in `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`, or organization defaults that are not visible locally.
- Top-level PR comments are not inline review comments. Use inline comments only when a specific changed line needs context.
- The review comment endpoint needs the PR head commit SHA, not an arbitrary local commit when the branch has moved.
