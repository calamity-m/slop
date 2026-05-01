---
tags:
  - debug
  - ai
---

# Prompt Template Snippets

## debug prompt

```
cat <<'PROMPT' | xclip -selection clipboard
## Debug Session

**Issue:**
<@issue>

**Log Output:**
<@logs:?paste log output here>

**Things Tried:**
<@tried:?what approaches have you already attempted>

**Leads / Hunches:**
<@leads:?any suspicions about root cause>
PROMPT
```
