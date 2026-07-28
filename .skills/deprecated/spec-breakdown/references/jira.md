# Publishing a breakdown to Jira

Uses the Jira Cloud REST API via `curl` — no CLI is assumed. Each ticket file
becomes one issue under an Epic created for the spec. Jira setups vary
(project keys, issue types, required fields), so resolve the specifics
against the instance instead of assuming; and creating issues is
outward-facing — confirm project, issue types, and the ticket list with the
user before the first POST.

## Preflight

Needs three values — ask the user for whichever aren't already in the
environment:

```bash
JIRA_URL="https://<site>.atlassian.net"
JIRA_EMAIL="user@example.com"
JIRA_API_TOKEN="..."            # from id.atlassian.com/manage-profile/security/api-tokens
auth=(-u "$JIRA_EMAIL:$JIRA_API_TOKEN" -H "Content-Type: application/json")
```

Plus the project key. Verify access and discover the real issue-type names
(don't assume "Epic"/"Story" — instances rename them):

```bash
curl -sf "${auth[@]}" "$JIRA_URL/rest/api/2/project/<KEY>" | jq '.issueTypes[].name'
```

Use API **v2**: its `description` accepts plain text, while v3 requires ADF
documents. Markdown is not Jira wiki markup — bodies mostly survive as plain
text, but convert headings/checklists to wiki markup (`h2.`, `* item`) if
fidelity matters to the user.

Skip any ticket whose index entry already records an issue URL —
re-publishing must not create duplicates.

## Create the epic

```bash
curl -sf "${auth[@]}" -X POST "$JIRA_URL/rest/api/2/issue" -d '{
  "fields": {
    "project": {"key": "<KEY>"},
    "issuetype": {"name": "Epic"},
    "summary": "<spec title>",
    "description": "<index Sequencing section + spec file reference>"
  }
}'
```

Company-managed projects may require an epic-name custom field — if the POST
returns a field error, inspect
`/rest/api/2/issue/createmeta?projectKeys=<KEY>&expand=projects.issuetypes.fields`
for what's required rather than guessing.

## Create the child issues

For each ticket file, H1 → `summary`, rest → `description`. Parent linking
differs by project type: team-managed accepts `"parent": {"key": "<EPIC>"}`;
company-managed may need the Epic Link custom field from createmeta.

```bash
curl -sf "${auth[@]}" -X POST "$JIRA_URL/rest/api/2/issue" -d "$(jq -n \
  --arg summary "$(head -1 "$f" | sed 's/^# *//')" \
  --arg desc "$(tail -n +2 "$f")" \
  '{fields: {project: {key: "<KEY>"}, issuetype: {name: "Story"},
    parent: {key: "<EPIC-KEY>"}, summary: $summary, description: $desc}}')"
```

The response's `key` gives the browse URL: `$JIRA_URL/browse/<key>`. Encode
"depends on" with issue links (`/rest/api/2/issueLink`, type "Blocks") when
the instance has that link type.

## Backfill

Write the URLs back into the breakdown markdown — the epic URL into the
index's "Published to" line, each child URL into its index entry. Then show
the user the epic URL.
