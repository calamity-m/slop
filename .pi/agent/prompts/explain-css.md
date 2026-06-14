---
description: Trace how CSS is applied to a component or screen and explain where and how to change it safely
argument-hint: "<component-or-screen> [known-leads]"
---

You are being tasked with explaining the styling of this part of the app:

```text
$1
```

Known starting leads from the user, if any:

```text
${@:2}
```

The target may be a single component, a screen, a widget, or a visual region the user can describe but not locate. For example: the header bar, a data table, a modal, or "the spacing around the login form".

The known leads may be files, component names, class names, selectors, screenshots, or notes the user already believes are relevant. Start from these leads, or at minimum include them in your initial search before broadening outward.

Assume the reader is a strong backend engineer who is not confident with CSS. Explain the styling mechanism plainly: what controls the look, where it lives, and why a change lands where it does. Do not assume familiarity with CSS methodologies, cascade rules, or the project's styling stack — state which ones are in play and what they imply. Prefer verified repository facts over speculation; where you cannot verify something, say so directly.

Your goal is not to implement anything. Your goal is to research the repository enough that the user can confidently make a styling change without breaking unrelated visuals.

Write your final report to:

```text
/tmp/css-report.md
```

Keep the report succinct, concrete, and file-oriented. If the file already exists, overwrite it completely.

Use this structure:

## Styling Stack

Name the approach this part of the app uses and what it means in practice: plain CSS, CSS Modules, Sass/Less, Tailwind or other utility classes, CSS-in-JS (styled-components, Emotion), inline styles, a component library (e.g. MUI, Bootstrap), or a mix. Note the one or two things about this stack the user must keep in mind to change it safely.

## Where the Styles Live

Trace the path from the component to its styles. For the target, identify:

- the component file(s) that render the markup
- the file(s) or class names that style it
- how the two are connected (imported class, utility string, theme value, global selector)
- any shared, global, or theme-level styles that also reach this element

## How a Change Applies

Explain in plain terms why a style takes effect here, and what could override or interfere with it: specificity, cascade order, shared classes used elsewhere, responsive breakpoints, or theme variables. Call out anything global or reused, since editing it would affect other screens.

## How to Make the Change

Give the concrete, lowest-risk way to make a typical change to this element (e.g. adjust spacing, color, or layout). Name the exact file and the line or selector to edit, and note whether the change is local to this element or shared. If a safer local-scoped option exists, recommend it.

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

Only include files that are actually useful for understanding or changing the styling. Do not include broad dumps of unrelated search results.
