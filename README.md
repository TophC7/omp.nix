# omp.nix

Toph's declarative [Oh My Pi](https://github.com/can1357/oh-my-pi) setup.

This foundation intentionally contains no migrated Pi extensions yet. It provides:

- pinned upstream OMP package and app;
- a Home Manager module wrapping OMP's native module;
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

## Validate

```sh
nix flake check
nix build
nix run
```

Future extension migration belongs on top of this foundation, not inside an OMP fork.
