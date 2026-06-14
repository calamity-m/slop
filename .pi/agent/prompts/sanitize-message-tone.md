---
description: Rewrite a message to use neutral or positive language instead of negative, harsh, or blunt phrasing, while preserving its meaning
argument-hint: "<message> [context-or-audience]"
---

You are being tasked with rewriting this message so its tone is neutral or positive rather than negative, harsh, or blunt:

```text
$1
```

Known context about the audience or situation, if any:

```text
${@:2}
```

The message may be a chat reply, a review comment, an email, a commit or MR note, a Slack message, or any other written communication. The context may name the recipient, the relationship, the channel, or the outcome the user wants.

Your goal is to preserve the original meaning and any concrete asks, decisions, or facts, while softening the delivery. Do not change what is being said — change how it lands. Keep the rewrite roughly as long as the original; do not pad it with filler or hollow positivity.

Apply these adjustments:

- Replace harsh or absolute words ("wrong", "broken", "never", "obviously", "you failed to") with neutral, specific framing.
- Turn blame and "you" accusations into observations about the work or situation ("this section does X" rather than "you did X wrong").
- Keep direct requests direct, but phrase them as asks rather than demands.
- Preserve disagreement and criticism when present — neutralize the tone, do not erase the substance or agree with something the user did not.
- Do not add greetings, sign-offs, emoji, or enthusiasm the user did not ask for unless the context clearly calls for it.
- Match the register of the channel (a code review reads differently from an email).

If the message is already neutral or positive, say so and return it unchanged rather than inventing problems.

If the message is ambiguous enough that softening it could change its meaning, note the ambiguity and offer the safest interpretation rather than guessing silently.

Respond directly in chat. Do not write to a file. Use this structure:

## Rewrite

The sanitized message, ready to copy and send. Nothing else in this section.

## What Changed

A short bullet list of the substantive tone changes you made and why, so the user can confirm the meaning is intact. Keep this to the edits that matter; skip trivial word swaps.

## Notes

Only if needed: flag anything you could not soften without altering meaning, any ambiguity you had to interpret, or an alternate phrasing if the right tone depends on context the user did not provide. Omit this section if there is nothing to add.
