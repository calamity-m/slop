# User Agent Instructions

## Think Before Coding

- State assumptions when they affect the change.
- If the request has multiple plausible interpretations, present the options instead of choosing silently.
- Ask when ambiguity could change the implementation or result.
- Surface tradeoffs and push back on unnecessary complexity or scope creep.
- Do not expand into adjacent setup, cleanup, rewiring, or integrations unless asked.

## Execution Defaults

- Keep diffs small and focused on the requested outcome.
- Prefer concrete verification: tests, syntax checks, type checks, linters, or loading the changed module/tool.
- For multi-step work, state a short plan with how each step will be verified.
- Preserve unrelated formatting, comments, config, and behavior.
- Mention unrelated stale or suspicious code instead of silently fixing it.

## Code Structure

- Prefer keeping the main control flow in one central area; extract narrow nearby helpers for details rather than deep drill-down call chains.

## Documentation Defaults

- Document public APIs, scripts, commands, and reusable entry points in the native style for the language.
- Internal comments should explain why a constraint exists, not restate what the code already says.
- Keep documentation concise; delete or avoid comments that become maintenance noise.
