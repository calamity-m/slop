---
tags:
  - jq
  - json
  - tools
---

# jq snippets

## select first array item from command output

```bash
<@command> | jq '.[0]'
```

## select first array item keys

```bash
jq '.[0] | keys'
```

## list object keys from command output

```bash
<@command> | jq 'keys'
```
