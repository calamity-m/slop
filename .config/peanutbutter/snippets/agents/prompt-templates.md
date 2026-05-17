---
tags:
  - debug
  - ai
---

# Prompt Template Snippets

## debug prompt

````bash
cat <<'PROMPT'
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
````
