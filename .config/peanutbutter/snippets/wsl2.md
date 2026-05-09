---
tags:
  - wsl2
  - windows
---

# WSL2 Snippets

## Open WSL path in Windows Explorer

```
explorer.exe "$(wslpath -w '<@path:?.>')"
```
