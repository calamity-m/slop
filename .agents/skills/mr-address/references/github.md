# GitHub PR Operations

Use this reference after the workflow identifies the target review as a GitHub pull request. Keep the checkpoint updated with command outputs that affect the next step.

## Required Identifiers

Collect these before acting:

- PR number or URL.
- Repository in `OWNER/REPO` form when outside the current checkout.
- Head branch, base branch, and current head SHA.
- Failed check names, run IDs, and job IDs.
- Comment, review, or review-thread identifiers for replies and resolution.

## Read PR Context

```bash
gh pr view <pr> \
  --json number,title,body,url,headRefName,baseRefName,headRefOid,files,comments,reviews,latestReviews,statusCheckRollup,closingIssuesReferences

gh pr diff <pr>
```

Read linked issues from `closingIssuesReferences` and from explicit URLs in the PR body or comments.

## Check Failed Jobs

Start with check status:

```bash
gh pr checks <pr> --json name,state,bucket,link,workflow,description,startedAt,completedAt
```

Treat `bucket == "fail"` as actionable, `pending` as a wait/recheck state, and `skipping` as non-actionable unless the repository expects the job to run.

For failed GitHub Actions jobs, identify the run/job and fetch failed logs:

```bash
gh run view <run-id> --json databaseId,name,status,conclusion,jobs,url
gh run view <run-id> --log-failed
gh run view <run-id> --job <job-id> --log
```

If a check is not backed by GitHub Actions, open or query the `link` from `gh pr checks` and capture the failing excerpt in the checkpoint before editing.

## Review Comments And Threads

`gh pr view --comments` is useful for top-level comments but does not expose all review-thread state. For line-level review threads, use GraphQL.

Fetch unresolved review threads:

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

Group threads by `path`, `line`, and concern before changing code. Record each thread ID and decision in the checkpoint.

## Reply To Comments

Prefer file-backed bodies for anything multiline or containing shell-sensitive characters:

```bash
gh pr comment <pr> --body-file <file>
```

For replies to review threads or review comments, prefer GraphQL mutations or the REST review-comment reply endpoint over posting a new top-level PR comment. Use the comment or thread ID collected during review-thread fetch.

For a review-comment reply through REST:

```bash
gh api \
  --method POST \
  repos/<owner>/<repo>/pulls/<pr>/comments/<comment-id>/replies \
  -f body="$(cat "$BODY_FILE")"
```

## Resolve Threads

Resolve only threads that are actually addressed:

```bash
gh api graphql -f query='
mutation($thread:ID!) {
  resolveReviewThread(input:{threadId:$thread}) {
    thread { id isResolved }
  }
}' -F thread=<thread-id>
```

If a thread was already resolved or outdated, record that in the checkpoint rather than replying again.

## Critical Gotchas

- `gh pr checks` may show external checks whose logs are not available through `gh run view`; follow the check `link`.
- `gh run view --log-failed` is usually enough for failed steps, but use `--job <job-id> --log` when the failed excerpt is incomplete.
- Top-level PR comments are not the same as review-thread replies. Do not lose context by replying at the wrong level.
- Always re-read checks after pushing because new commits can invalidate previous run IDs and job IDs.
