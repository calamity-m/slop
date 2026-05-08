# GitHub PR Review

Use this reference after the workflow identifies the target review as a GitHub pull request.

## Required Identifiers

Collect these before posting comments:

- Repository in `OWNER/REPO` form.
- PR number or URL.
- Head branch, base branch, and PR head commit SHA.
- Changed file paths and target line numbers.
- Review thread identifiers for existing discussions.

## Read PR Context Before Diff

Read title, description, linked issues, review state, and comments before fetching the diff:

```bash
gh pr view <pr> \
  --json number,title,body,url,author,headRefName,baseRefName,headRefOid,isDraft,labels,comments,reviews,closingIssuesReferences
```

Read linked issues from `closingIssuesReferences` and explicit URLs in the PR body, comments, commits, or branch name. Treat linked context as review input, not as proof the code is correct.

Fetch unresolved review threads through GraphQL:

```bash
gh api graphql -f query='
query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          path
          line
          startLine
          comments(first:100) {
            nodes {
              id
              databaseId
              body
              author { login }
              createdAt
              url
            }
          }
        }
      }
    }
  }
}' -F owner=<owner> -F repo=<repo> -F number=<number>
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

Fetch diff metadata and full patch:

```bash
gh pr diff <pr> --name-only
gh pr diff <pr>
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
git fetch origin <base-branch>
git show origin/<base-branch>:<path>
git diff origin/<base-branch>...HEAD -- <path>
```

For broader exploration, create a temporary worktree outside the repository:

```bash
git worktree add /tmp/mr-review/base-<review-id> origin/<base-branch>
```

Remove temporary worktrees only when the review is finished and the user has not asked to keep artifacts.

## Line Comments

Prefer inline comments for code findings. Required fields include `body`, `commit_id`, `path`, `line`, and `side`.

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

Use `side=LEFT` for removed lines. Use `start_line` and `start_side` for multi-line comments.

Use a detached PR comment only for review-request-level concerns:

```bash
gh pr comment <pr> --body-file <body-file>
```

## Critical Gotchas

- `gh pr view --comments` misses important review-thread state; use GraphQL for review threads.
- Inline comment line numbers must match the PR diff position and head commit SHA.
- Re-fetch PR metadata after the branch is updated because head SHA and line positions can change.
- Do not comment on every observation from the record; post only confirmed actionable findings.
