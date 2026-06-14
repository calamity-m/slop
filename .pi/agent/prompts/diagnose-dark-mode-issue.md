---
description: Trace why something renders wrong in dark mode and identify the safest fix
argument-hint: "<dark-mode-symptom> [known-leads]"
---

You are being tasked with diagnosing this dark mode issue:

```text
$1
```

Known starting leads from the user, if any:

```text
${@:2}
```

The symptom may be anything that looks wrong when dark mode is active: unreadable text, an element stuck on a light background, an icon that disappears, a flash of the wrong theme on load, a control whose colors never switch, or a region that only half-themes. The user can usually describe what they see but not where it comes from.

The known leads may be files, component names, class names, selectors, CSS variables, theme tokens, screenshots, or notes the user already believes are relevant. Start from these leads, or at minimum include them in your initial search before broadening outward.

Assume the reader is a strong backend engineer who is not confident with CSS or theming. Explain the theming mechanism plainly: how the app knows it is in dark mode, how that reaches the failing element, and why this element did not get the memo. Do not assume familiarity with the cascade, color tokens, or the project's theming stack — state which ones are in play and what they imply. Prefer verified repository facts over speculation; where you cannot verify something, say so directly.

Your goal is not to implement anything. Your goal is to research the repository enough to name the root cause and the lowest-risk fix, so the user can change it without breaking light mode or unrelated screens.

Write your final report to:

```text
/tmp/dark-mode-report.md
```

Keep the report succinct, concrete, and file-oriented. If the file already exists, overwrite it completely.

Use this structure:

## Theming Mechanism

How dark mode is implemented in this app and what that means in practice. Identify which approach is in use: a `class`/`data-theme` toggle on a root element, `prefers-color-scheme` media queries, CSS custom properties (variables), a component library's theme provider (e.g. MUI, Chakra, Tailwind `dark:`), inline JS-driven styles, or a mix. Note where the active theme is decided and stored (root attribute, context/provider, localStorage, server-rendered value) and the one or two things about this mechanism the user must keep in mind.

## How the Theme Reaches the Element

Trace the path from the theme switch to the failing element. For the target, identify:

- the component file(s) that render the markup
- the file(s), class names, or tokens that color it
- how the active theme is supposed to flow in (variable, `dark:` variant, theme prop, scoped selector)
- where in that chain the dark value is missing, hardcoded, or overridden

## Root Cause

Name why this element fails in dark mode, in plain terms. Common causes to confirm or rule out:

- a hardcoded color (hex/rgb) instead of a theme token or variable
- a missing dark-mode variant, override, or `prefers-color-scheme` branch
- specificity or cascade order letting a light rule win
- an element rendered outside the themed root (portal, modal, iframe, `body`-level node)
- an asset that does not adapt (a fixed-color image, SVG, or icon)
- theme applied too late, causing a flash of the wrong theme
- a token that is defined but resolves to the wrong value in the dark scope

State the single most likely cause and the evidence for it. If more than one defect contributes, list them in order of impact.

## How to Fix It

Give the concrete, lowest-risk fix. Name the exact file and the line or selector to edit, what to change it to, and whether the change is local to this element or shared. Call out anything global or reused, since editing it would affect light mode or other screens. If the safe fix is to adopt an existing theme token rather than add a new color, recommend that. If verifying the fix needs a manual check (toggle the theme, reload to catch a flash), say what to look at.

## Repository Map

List the files and line ranges to inspect first.

Use this format:

```text
Critical Files:
-> path/to/file.ext - Shortest useful description
   -> lines 10-24 - What this block contributes
   -> lines 80-96 - What this block contributes
-> another/path.ext - Shortest useful description
   -> lines 5-12 - What this block contributes
```

Only include files that are actually useful for understanding or fixing the issue. Do not include broad dumps of unrelated search results.
