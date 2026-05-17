---
tags:
  - git
  - gitlab
  - development
---

# GitLab CLI Snippets

## Clone repository

```bash
glab repo clone <@owner>/<@repository>
```

## Create merge request

```bash
glab mr create
```

## View merge request in browser

```bash
glab mr view --web <@mr_number>
```

## Check out merge request locally

```bash
glab mr checkout <@mr_number>
```
