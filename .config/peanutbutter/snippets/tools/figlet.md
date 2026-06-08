---
tags:
  - figlet
  - ascii
  - tools
variables:
  text:
    default: Hello
  font:
    command: "npx --yes figlet -l 2>/dev/null | sed '/^$/d; /^Available fonts:/d' | sort"
  width:
    default: "80"
---

# figlet snippets

## Render text as ASCII art

```bash
npx --yes figlet "<@text>"
```

## Render text with selected font

```bash
npx --yes figlet -f "<@font>" "<@text>"
```

## Render text with selected font and width

```bash
npx --yes figlet -f "<@font>" -w <@width> "<@text>"
```

## List usable fonts

```bash
npx --yes figlet -l 2>/dev/null | sed '/^$/d; /^Available fonts:/d' | sort
```

## Preview usable fonts

```bash
npx --yes figlet -l 2>/dev/null | sed '/^$/d; /^Available fonts:/d' | sort | while read -r font; do printf '\n== %s ==\n' "$font"; npx --yes figlet -f "$font" "<@text>"; done
```
