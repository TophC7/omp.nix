import type { ExtensionAPI, ExtensionCommandContext } from "@oh-my-pi/pi-coding-agent";
import reviewPrompt from "./lib/review-adversarial.md" with { type: "text" };

function renderReviewPrompt(request?: string): string {
	return reviewPrompt.replaceAll("{{REQUEST}}", () => request || "<none>");
}

export default function reviewAdversarialExtension(pi: ExtensionAPI): void {
	pi.registerCommand("review:adversarial", {
		description: "Run six-scope adversarial review over any target and apply selected fixes",
		handler: async (args, ctx: ExtensionCommandContext) => {
			await ctx.waitForIdle();
			pi.sendUserMessage(renderReviewPrompt(args?.trim()));
		},
	});
}
