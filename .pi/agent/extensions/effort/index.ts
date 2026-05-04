import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const levels = ["off", "minimal", "low", "medium", "high", "xhigh"] as const;
type EffortLevel = (typeof levels)[number];

function isEffortLevel(value: string): value is EffortLevel {
	return levels.includes(value as EffortLevel);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("effort", {
		description: "Set thinking effort: off, minimal, low, medium, high, xhigh",
		handler: async (args, ctx) => {
			const requested = (args ?? "").trim().toLowerCase();

			let level: EffortLevel | undefined;
			if (requested) {
				if (!isEffortLevel(requested)) {
					ctx.ui.notify(`Unknown effort '${requested}'. Use: ${levels.join(", ")}`, "error");
					return;
				}
				level = requested;
			} else if (ctx.hasUI) {
				const selected = await ctx.ui.select("Select thinking effort", [...levels]);
				if (!selected) return;
				level = selected;
			} else {
				ctx.ui.notify(`Current effort: ${pi.getThinkingLevel()}. Use /effort <${levels.join("|")}>`, "info");
				return;
			}

			pi.setThinkingLevel(level);
			ctx.ui.notify(`Thinking effort: ${pi.getThinkingLevel()}`, "info");
		},
	});
}
