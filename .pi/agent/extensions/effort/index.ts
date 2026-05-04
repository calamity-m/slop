// `import type` brings in TypeScript type information without adding any
// runtime JavaScript import. We only need `ExtensionAPI` so TypeScript can tell
// us what methods `pi` has, such as `registerCommand()` and `setThinkingLevel()`.
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// Pi supports these thinking levels. `as const` tells TypeScript this is not a
// generic `string[]`; it is an exact list of literal string values. That lets us
// derive a safe type from the array instead of writing the same list twice.
const levels = ["off", "minimal", "low", "medium", "high", "xhigh"] as const;

// This becomes the union type:
// "off" | "minimal" | "low" | "medium" | "high" | "xhigh"
// If we add or remove a value in `levels`, this type updates automatically.
type EffortLevel = (typeof levels)[number];

// User input starts as an arbitrary string. This helper checks whether the input
// is one of our known levels. The `value is EffortLevel` return type is called a
// type predicate: after this function returns true, TypeScript knows `value` is
// safe to pass to `pi.setThinkingLevel()`.
function isEffortLevel(value: string): value is EffortLevel {
	return levels.includes(value as EffortLevel);
}

// Pi loads extension files by calling their default export and passing in the
// extension API. Register commands, tools, and event handlers inside this
// function so Pi can wire them into the running agent.
export default function (pi: ExtensionAPI) {
	// This creates a slash command named `/effort`.
	// Examples:
	//   /effort high    -> set thinking to high immediately
	//   /effort         -> open a picker in interactive mode
	pi.registerCommand("effort", {
		description: "Set thinking effort: off, minimal, low, medium, high, xhigh",
		handler: async (args, ctx) => {
			// Command arguments are whatever the user typed after `/effort`.
			// `(args ?? "")` protects us if Pi ever passes undefined/null here.
			// `trim()` ignores accidental spaces, and `toLowerCase()` accepts
			// friendly input like `/effort HIGH`.
			const requested = (args ?? "").trim().toLowerCase();

			let level: EffortLevel | undefined;
			if (requested) {
				// If the user supplied an argument, require it to be one of the
				// exact supported values. Returning early avoids calling Pi with an
				// invalid thinking level.
				if (!isEffortLevel(requested)) {
					ctx.ui.notify(`Unknown effort '${requested}'. Use: ${levels.join(", ")}`, "error");
					return;
				}
				level = requested;
			} else if (ctx.hasUI) {
				// With no argument in interactive mode, show a small selection UI.
				// `ctx.hasUI` matters because print/JSON modes do not have a terminal
				// interface that can ask the user questions.
				const selected = await ctx.ui.select("Select thinking effort", [...levels]);
				if (!selected) return;
				level = selected;
			} else {
				// In non-interactive modes, avoid opening UI. Instead, tell the user
				// what the current value is and how to set a new one explicitly.
				ctx.ui.notify(`Current effort: ${pi.getThinkingLevel()}. Use /effort <${levels.join("|")}>`, "info");
				return;
			}

			// Pi may clamp the requested level depending on the selected model. For
			// example, a model without reasoning support may force thinking `off`.
			// Reading it back with `getThinkingLevel()` reports the actual final value.
			pi.setThinkingLevel(level);
			ctx.ui.notify(`Thinking effort: ${pi.getThinkingLevel()}`, "info");
		},
	});
}
