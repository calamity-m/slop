import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("clear", {
		description: "Start a fresh session with no previous message history",
		handler: async (_args, ctx) => {
			const currentSession = ctx.sessionManager.getSessionFile();

			const result = await ctx.newSession({
				parentSession: currentSession,
				withSession: async (replacementCtx) => {
					replacementCtx.ui.setEditorText("");
					replacementCtx.ui.notify("Cleared session history", "info");
				},
			});

			if (result.cancelled) {
				ctx.ui.notify("Clear cancelled", "info");
			}
		},
	});
}
