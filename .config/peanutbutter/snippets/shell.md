---
name: Shell
---

# Shell Snippets

Snippets for shell behavior and control flow

## Run command without saving to history

```bash
<@command>; history -d $(history 1)
```

## If/else one liner

```bash
if [[ <@condition> ]]; then <@then>; else <@else>; fi
```
