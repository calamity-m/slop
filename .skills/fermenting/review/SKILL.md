---
name: review
description: Review code for conventions, correctness, maintainability and complexity. Use when the user asks for a code review, a mr review, pr review or to review changes on a branch.
---

# Review

Review code with an adversarial mindset to ensure quality does not drop for maintainability, complexity or correctness.

## Core Prompt

> Perform an adversarial code review focused on identifying failures in the proposed code changes.
> Validate and audit if the proposed changes adequately address the problems it claims to.
> Question whether the problem has been understood correctly, when taking into context of the codebase enlarge.
> Flag styling inconsistencies, but do not get distracted or held back by them - focus on the core of the code changes.
> Be ambitious, code accepted remains. Be thorough. Be riguorous.

## Key Review Areas

### Proximate Versus Ultimate Cause

Pay attention to a particular trap that code can find itself in, solving a proximate cause as opposed to the ultimate cause.
A proximate cause is the immediately noticed problem while ultimate is the originator of a chain of events.

Consider these examples:

<example_one>
PROBLEM: Room is too hot.
PROXIMATE CAUSE: Heat energy coming in is greater than heat energy leaving.
PROPOSED SOLUTION: Open windows and turn on the fans to increase the amount of heat leaving.
ULTIMATE CAUSE: The thermostat is set too high.
REAL SOLUTION: Turn down the thermostat.
</example_one>

<example_two>
PROBLEM: Boat is sinking.
PROXIMATE CAUSE: Gravity is stronger than buoyancy
SOLUTION: Reduce gravity by lightening the boat.
ULTIMATE CAUSE: The boat has a hole in the hull.
REAL SOLUTION: Repair the hole in the hull.
</example_two>

In both of the above examples, the proximate cause falls into a "local minima" of the problem-solution space, and incorrectly identifies the root cause of an issue.

Ensure and validate that the code being proposed does not fall into this trap. An adversarial reviewer ensures to validate the ultimate cause before approving a potential solution.

### Intentional and Unchanged Behavior Are Not Exemptions

Treat the PR's stated tradeoffs, compatibility promises, and exclusions as claims to evaluate—not unquestionable constraints.

- Separate implementation fidelity ("matches the specification") from semantic correctness ("the specification produces useful, coherent behavior").
- Label defects as introduced, exposed, or pre-existing. Don't discard a relevant defect solely because it predates the change.
- For ranking or heuristic changes, test representative competing outcomes under default configuration. Formula checks and custom-weight tests do not establish result quality.
- Compatibility tests can faithfully preserve bugs. State what verification establishes and what remains untested.

### Spaghetti Trails

Technical debt is easy to add, hard to remove. Technical debt mounts slowly, but becomes apparent all at once.
Proposed code changes may address the ultimate cause of a problem, but be marred in over-engineering, extreme repetition,
pre-emptive abstraction and other complexities. An adversarial reviewer ensures that complexity added to the code-base is worthwhile.

### Hidden Logic Failures

Particularly large code changes have an extremely high chance of containing logic bugs laying hidden within changes. Consider the following examples:

<example_one>
CODE CHANGE: Subsequent database writes in a single function without transaction
OBVIOUS BUG: Transaction missing, causing rollback and failed state issues
HIDDEN BUG: Database writes forgot to set key column
</example_two>

<example_one>
CODE CHANGE: A popup dialog with custom styling is added, allowing for prop passed icons
OBVIOUS BUG: Does not follow styling guidelines
HIDDEN BUG: Dialog interacts with state and opens all popup dialogs in the UI, not just the desired instance
</example_two>

Both of these examples have causes of critical logic issues hidden inside of larger issues, or large consistency/code-base complexity issues. An adversial reviewer ensures that while the obvious bugs are flagged, hidden bugs are not skipped over. Edge cases are killers. They must be considered.

## Findings

Findings are not required. Report only supported issues, but do not exempt deliberate design decisions from scrutiny.
Do not allow critical findings to be drowned out by a flood of low-severity nitpicks. Never surface vague suggestions or untested and unsupported hypothesises.

## Review Output

All output of a review should follow this format:

[Severity | Issue] finding

Severity

- Nit -> Lowest severity. A nit is a preference change, a small correction or isolated styling change.
- Serious -> Middle severity. Serious is an issue that requires resolving or clarification, leading to potential further discussion.
- Critical -> Highest severity. Critical is reserved for issues that cannot be negotiated - critical bugs or invalid architecture and approach to a problem.

Issue

- Bug -> Used when a "bug", some portion of the code that will not work as expected or has not been accounted for is found.
- Complexity -> Used when findings attack a code's complexity.
- Doc -> Used for documentation related findings.
- Approach -> Used when a finding is concerned with the approach, design or architecture of code

Finding text themselves should be direct and succinct, but never rude. We do not want to leave ambiguity. Do not command, but do not soften findings into meagre suggestions.

Rude finding text (BAD):

- This code doesn't work and is designed incorrectly, complexity is way too high for a simple function.

Soft finding text (BAD):

- I think potentially, there may be some complexities here that could potentially be simplified. I think maybe you might want to consider changing this?

Acceptable finding text (GOOD):

- This function is fairly complex. Recommend simplifying to increase readability.
- Code works here, but decomposing this method will allow for future extensibility.
- The complexity here is hard to grasp without thorough reading. Recognising this is a difficult issue, a different approach may be wise to employ here.
