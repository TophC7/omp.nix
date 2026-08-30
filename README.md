# omp.nix

Toph's declarative [Oh My Pi](https://github.com/can1357/oh-my-pi) setup.

This configuration provides:

- pinned upstream OMP and Context Mode packages;
- a Home Manager module wrapping OMP's native module;
- Nix-managed Context Mode CLI, OMP plugin, and MCP registration;
- native Caveman and Ponytail prompt toggles;
- `/cleanup` with dedicated reuse, quality, and efficiency scouts;
- baseline model, thinking, appearance, and notification settings;
- Toph's global Soul at `~/.omp/agent/AGENTS.md`;
- module and package checks.

## Use

```nix
{
  inputs.omp-nix.url = "ssh://git@git.ryot.foo:222/toph/omp.nix.git";

  # In Home Manager:
  imports = [ inputs.omp-nix.homeManagerModules.default ];
  programs.omp.enable = true;
}
```

`programs.omp.package` and `programs.omp.settings` remain available from OMP's upstream Home Manager module. Consumer definitions can override this flake's baseline settings normally.

The flake and Home Manager module currently support `x86_64-linux`.

## Context Mode

Context Mode 1.0.169 is built from its tagged upstream release. The module installs its CLI, links its native OMP plugin under `~/.omp/plugins/node_modules`, and merges the MCP server entry into OMP's writable `mcp.json` during Home Manager activation. Unrelated MCP servers and plugin dependencies are preserved.

Context Mode's databases remain mutable runtime state under `~/.omp/context-mode`; Nix does not own or replace them.

## Prompt toggles

Caveman and Ponytail load as native OMP extensions. Both default to enabled and expose `/caveman [on|off]` and `/ponytail [on|off]`; their defaults persist under `~/.omp/agent`.

## Cleanup command

`/cleanup [focus]` reviews the complete working-tree diff with three dedicated read-only scouts running in parallel, then applies only safe, in-scope findings. The command preserves the original reuse, quality, and efficiency passes and never stages or commits its fixes.

## Validate

```sh
nix flake check
nix build
nix run
```

Future extension migration belongs on top of this foundation, not inside an OMP fork.
