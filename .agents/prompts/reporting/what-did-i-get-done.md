---
description: Summarize your completed work across GitHub/GitLab repositories for a time window
argument-hint: "<time-window> [repo|owner|group|path ...]"
---

Summarize what I got done for this scope:

```text
$ARGUMENTS
```

The first part should be a time window, such as `yesterday`, `today`, `last 3 days`, `this week`, `2026-06-01..2026-06-07`, or `since Monday`. Any remaining arguments are repository scopes. A repository scope may be:

- a local repository path
- a GitHub repository (`owner/repo` or `github:owner/repo`)
- a GitLab project (`group/project` or `gitlab:group/project`)
- a GitHub owner/org (`github:owner`)
- a GitLab group (`gitlab:group`)
- a full GitHub/GitLab URL

If no repository scope is supplied, inspect the current git repository when inside one. If the user clearly asks for cross-repository work but gives no scope, use authenticated `gh`/`glab` searches across accessible repositories; otherwise state the scope assumption before reporting.

## Workflow

1. Resolve the requested time window into concrete local dates/times. Use a start-inclusive, end-exclusive interval when querying.
2. Resolve my identities:
   - local git author emails: `git config user.email`, `git config --global user.email`, and repository-specific emails when local paths are inspected
   - GitHub login: `gh api user --jq .login`
   - GitLab username: `glab api user --jq .username` or `glab api graphql -f query='query { currentUser { username } }'`
3. Resolve repository scopes into a deduplicated list of concrete repositories/projects. Detect forge from explicit prefixes, URLs, or git remotes. For owner/group scopes, enumerate repositories conservatively:
   - GitHub: `gh repo list <owner> --no-archived --limit 200 --json nameWithOwner,url,pushedAt`
   - GitLab: `glab repo list --group <group> --include-subgroups --archived=false --per-page 100 --output json`
4. Gather merged PRs/MRs authored by me during the time window:
   - GitHub repo: `gh search prs --author @me --merged --merged-at <start>..<end> --repo <owner/repo> --json title,number,url,repository,mergedAt,body,labels`
   - GitHub owner/org: same command with `--owner <owner>` instead of `--repo`
   - GitLab all accessible: `glab api "merge_requests?scope=created_by_me&state=merged&updated_after=<start>&updated_before=<end>&per_page=100" --paginate`, then filter `merged_at` into the exact window with `jq`
   - GitLab project: `glab api "projects/<urlencoded-project>/merge_requests?state=merged&author_username=<username>&updated_after=<start>&updated_before=<end>&per_page=100" --paginate`, then filter `merged_at` into the exact window with `jq`
5. Gather authored non-merge commits in the same window, including direct pushes and work without PR/MR context:
   - Local git: `git log --since=<start> --until=<end> --author=<email-or-name> --no-merges --format='%h%x09%ad%x09%s' --date=short`
   - GitHub: `gh search commits --author <github-login> --author-date <start>..<end> --repo <owner/repo> --json sha,commit,repository,url --limit 100`, then ignore commits with more than one parent when parent data is available
   - GitLab: `glab api "projects/<urlencoded-project>/repository/commits?since=<start>&until=<end>&author=<email-or-name>&per_page=100" --paginate`, then ignore merge commits when the title/message indicates a merge or parent data is available
6. Deduplicate commits that are already represented by merged PRs/MRs. Prefer the PR/MR as the unit of work, with commit hashes only as supporting evidence.
7. Synthesize the important completed work. Prioritize shipped behavior, architecture, fixes, migrations, tooling, tests, and operational changes. Omit cosmetic-only changes, routine version bumps, formatting-only commits, and minor renames unless they are the only work found.

## Guardrails

- Be concise and information-dense.
- Do not infer motivation. Describe changes functionally.
- Distinguish landed work from in-flight work. The main answer should focus on merged PRs/MRs and authored commits in the time window.
- If a CLI is missing, unauthenticated, rate-limited, or lacks access, say so and fall back to available local git evidence.
- If a broad owner/group search would be huge, cap the search, report the cap, and prefer repositories with activity in the time window.
- Include the real date range and repository scope actually inspected.

## Output

Return a status-update-ready summary in this structure:

```markdown
## What I got done

<Date range> across <repo scope inspected>.

<One concise paragraph written as a leadership/weekly-meeting status update, summarizing the most important completed work and its practical impact.>

- <major completed item> — <repo>, <PR/MR # or commit hash>
- <major completed item> — <repo>, <PR/MR # or commit hash>
- <major completed item> — <repo>, <PR/MR # or commit hash>

## Evidence checked

- Repositories/projects: <count and names, or scope query>
- Forge data: <GitHub/GitLab commands used, or unavailable reason>
- Git data: <local paths or commit searches used>
- Gaps: <auth/access/rate-limit/scope gaps, or "none noted">
```

Use 2-5 bullets for major changes. If there was no meaningful completed work in the window, say that directly and include the evidence checked.
