---
tags:
  - mise
  - tools
---

# Mise Snippets

## upgrade mise tools and commit lock

Upgrade all mise tools, then commit and push the updated lock file.

```bash
cd ~/code/slop && mise upgrade && git add .config/mise/mise.lock && git commit -m "chore(mise): update deps" && git push
```
