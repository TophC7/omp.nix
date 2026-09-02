# omp.nix

Toph's [Oh My Pi](https://github.com/can1357/oh-my-pi) setup, owned by Nix: package, settings, agent prompt, workflow commands, scout agents, and the Context Mode MCP server, reproducible without a global npm install.

Upstream OMP already ships its own Home Manager module and most of the runtime. This repo is the personal layer on top: opinionated defaults, a small set of workflows worth keeping, and one pinned MCP server.

## What this provides

- **Upstream OMP, pinned** through `inputs.omp`, re-exported as packages, apps, and checks for `x86_64-linux`.
- **A Home Manager module** that imports upstream's module and layers personal defaults over it — every option stays overridable (`lib.mkDefault` throughout).
- **Global agent identity** through `omp/AGENTS.md`, installed as `~/.omp/agent/AGENTS.md`.
- **Two prompt toggles** (`/caveman`, `/ponytail`) that persist across sessions and branches.
- **Two scout swarms** for review and cleanup, plus a PR command.
- **Context Mode** built from a pinned source rev with bun2nix and registered as both an MCP server and an OMP plugin.

## Use

Add the flake input:

```nix
{
  inputs.omp-nix.url = "github:tophc7/omp.nix";
}
```

Import the Home Manager module:

```nix
{
  imports = [ inputs.omp-nix.homeManagerModules.default ];

  programs.omp.enable = true;
}
```

There are no options of our own. `programs.omp.*` is upstream's option set; anything set here is a default you can override, including `package` and every key under `settings`.

## What Nix owns

`nix/default.nix` writes the personal half of `programs.omp.settings`:

- discovery isolated to native OMP sources and OMP-installed plugins — every foreign provider (`claude`, `codex`, `cursor`, `gemini`, `vscode`, `mcp-json`, …) is disabled;
- `openai-codex/gpt-5.6-sol` as default model, `high` fallback thinking, prose-only thinking blocks;
- `yolo` tool approval, Bash on with direnv integration off, Python eval off with a session-scoped kernel;
- quiet startup without update checks, summary changelogs, nerd symbols, and a Claude-shaped composer;
- pipe-separated accented status, compact thinking level, terminal progress, append-only resize scrollback, text sizing, hyperlinks, token usage, and turn time on screen;
- AutoQA consent plus checkpoint, GitHub, and rendered-Markdown tools on; memory and marketplace auto-updates off; default tree filtering and mechanical unexpected-stop detection;
- completion/error/ask desktop notifications on.

It also links `omp/` into `~/.omp/agent/` and installs Context Mode into the user profile.

## Workflows

| Command | What it does |
| --- | --- |
| `/review:adversarial [target]` | Acquires a review target — PR, merge base, staged/unstaged Git, Jujutsu working copy, a commit, paths, or an external repo — then runs six read-only scouts (architecture, reuse, idiom, quality, efficiency, comments) in one batch, synthesizes a verdict, and triages every actionable finding through one `ask` call before applying the chosen repairs. |
| `/cleanup [focus]` | Pre-commit polish. Captures the full `git diff HEAD`, runs three scouts (reuse, quality, efficiency), applies only clearly-correct findings, and reports applied / skipped / worth-a-look. |
| `/pr [guidance]` | Drafts and opens a GitHub PR from committed merge-base changes. Treats `dev/*` as local-only and creates a `pr/*` pointer instead, never force-pushes, pushes at most once, and creates the PR through the native `github` tool. |

All three stop short of staging, committing, or pushing your work; review and cleanup leave the tree for you to inspect.

`/review:adversarial` is an extension so the prompt can be sent as a real user turn after `waitForIdle`; `/cleanup` and `/pr` are plain command markdown.

## Prompt toggles

| Toggle | Effect |
| --- | --- |
| `/caveman [on\|off]` | Terse register: drops articles, filler, and hedging while keeping technical substance and code intact. |
| `/ponytail [on\|off]` | Lazy-senior heuristics: reuse before writing, stdlib before dependency, no speculative abstraction — without letting line count excuse duplication or weak seams. |

Both are on by default and share `omp/extensions/lib/prompt-toggle.ts`: state lives in `~/.omp/agent/<name>.json`, is appended to the session as an entry, and is restored on session start, switch, branch, and tree navigation so a forked conversation keeps the register it was written in.

## Soul

`omp/AGENTS.md` is the human part. Creative partner, not contractor: choose on merit rather than the literal mechanism, protect readability, one concept one home, Nix/Bun/Fish over Python, ask when intent is ambiguous, sign only when asked.

## Context Mode

Context Mode runs commands and processes files in a sandbox, returning only what matters, and keeps an FTS5 knowledge base for indexed content.

`nix/context-mode.nix` builds it from the pinned `context-mode` source input with bun2nix and the generated lock in `nix/locks/`. The `ompContextMode` activation script then merges it into two files with `jq`, preserving unrelated entries:

- `~/.omp/agent/mcp.json` — stdio server entry pointing at the store path, with `CONTEXT_MODE_DIR` set to `~/.omp/context-mode/` so the search database stays mutable;
- `~/.omp/plugins/package.json` — a `file:` dependency so OMP loads it as a plugin, backed by a `~/.omp/plugins/node_modules/context-mode` link.

## Repo map

```text
flake.nix                     inputs, packages, apps, checks, formatter
nix/default.nix               Home Manager module: settings, links, activation
nix/context-mode.nix          bun2nix build of the pinned Context Mode source
nix/locks/                    generated Bun lock
omp/AGENTS.md                 global agent prompt
omp/extensions/               caveman, ponytail, review-adversarial
omp/extensions/lib/           shared prompt-toggle + review prompt
omp/agents/                   6 review scouts, 3 cleanup scouts
omp/commands/                 cleanup, pr
```

## Checks

`nix flake check` evaluates the exported packages and runs one Home Manager module smoke test covering package installation, activation/file wiring, and setting override precedence. `nix fmt` runs `nixfmt` over every `.nix` file.
