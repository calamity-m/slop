---
description: Refactor a React component to delegate part of its functionality to a new shared component, interviewing the user about scope when the extraction is non-trivial
argument-hint: "<component-path> [notes]"
---

You are being tasked with extracting shared functionality out of an existing React component into a new reusable component, then refactoring the original to use it:

```text
$ARGUMENTS
```

The first argument is the path to the React component to refactor. Anything after that is notes from the user about what they want shared, where the shared component should live, or constraints on the refactor.

## 1. Read the component

Read the target component fully, plus enough of its surroundings to understand it:

- Its props, internal state, effects, context usage, and rendered structure.
- Where it is used (search for imports of it) so you know what behavior must not change.
- The project's existing conventions for shared components: where they live (e.g. `components/`, `shared/`, `ui/`), how they are named, styled, typed, and tested. If a design-system or ui library is already in use, note it — the extraction should fit it, not compete with it.

## 2. Decide: trivial or not

The extraction is **trivial** only when all of these hold: the piece to share is a single obvious render block or hook, it has one clear seam (no entangled state or callbacks crossing the boundary), and the user's notes already say what to extract. In that case, skip to step 4.

Otherwise it is **non-trivial** — and you must grill the user before writing any code.

## 3. Grill the user (non-trivial only)

Do not guess the boundary of a shared component; a wrong guess produces a leaky abstraction that every future caller pays for. Interview the user with pointed, concrete questions grounded in what you just read — quote actual prop names, state variables, and JSX blocks from the component. Cover whichever of these are genuinely unresolved:

- **What exactly is shared?** Which of the render blocks/behaviors you identified should move into the shared component, and which stay behind? Offer your best-guess seam and let them correct it.
- **Who else will use it?** Is there a second consumer today, or is this speculative? If other components already duplicate this functionality, name them and ask whether they're in scope to migrate now or later.
- **State ownership.** For each piece of state crossing the seam: does the shared component own it, or is it controlled by the parent via props/callbacks?
- **Props API.** Where behavior currently varies (conditionals, styling branches, handlers), should the shared component take a prop, a render prop/slot (`children`), or just not support that variation yet?
- **Styling and naming.** Where should it live, what should it be called, and does it inherit the original's styles or get its own?

Ask in one or two focused rounds, not a drip-feed. Push back if the user's answers imply premature generality (props nobody needs yet) — the smallest API that serves the known consumers wins. Stop grilling once the seam, API, and location are pinned down; state the agreed design in a short summary before coding.

## 4. Extract and refactor

1. Create the shared component in the agreed (or convention-derived) location, with the agreed props API, typed and documented in the project's existing style.
2. Move the shared markup/logic into it verbatim where possible — this is a refactor, not a rewrite. Resist improving unrelated code on the way through.
3. Refactor the original component to render the shared component, deleting the now-duplicated code.
4. If the user agreed to migrate other duplicating components in step 3, refactor those too; otherwise leave them and mention them at the end.

The original component's observable behavior — rendered output, event handling, accessibility attributes — must be unchanged from its consumers' point of view.

## 5. Verify

- Run the project's typecheck and lint over the touched files.
- Run existing tests that cover the original component; they should pass unmodified (snapshot updates are a smell — investigate before accepting them).
- If the project has a straightforward way to render the component (dev server, Storybook, test harness), exercise it and confirm the refactored component renders and behaves as before.

Finish by reporting: the shared component's path and props API, what changed in the original, which duplicating components were migrated or deliberately left, and exactly which verification steps ran or were skipped.
