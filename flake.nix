{
  description = "omp.nix - Toph's Oh My Pi configuration";

  inputs = {
    omp.url = "github:can1357/oh-my-pi";
    nixpkgs.follows = "omp/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      omp,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeManagerModules = {
        omp = import ./nix { inherit omp; };
        default = self.homeManagerModules.omp;
      };

      packages.${system} = {
        inherit (omp.packages.${system}) omp;
        default = omp.packages.${system}.default;
      };

      apps.${system} = {
        inherit (omp.apps.${system}) omp;
        default = omp.apps.${system}.default;
      };

      checks.${system} = {
        inherit (omp.checks.${system}) omp;

        module =
          let
            evaluated = pkgs.lib.evalModules {
              specialArgs = { inherit pkgs; };
              modules = [
                {
                  options = {
                    home.packages = pkgs.lib.mkOption {
                      type = pkgs.lib.types.listOf pkgs.lib.types.package;
                      default = [ ];
                    };
                    home.activation = pkgs.lib.mkOption {
                      type = pkgs.lib.types.attrsOf pkgs.lib.types.anything;
                      default = { };
                    };
                    home.file = pkgs.lib.mkOption {
                      type = pkgs.lib.types.attrsOf pkgs.lib.types.anything;
                      default = { };
                    };
                  };
                }
                self.homeManagerModules.default
                {
                  programs.omp.enable = true;
                  programs.omp.settings.modelRoles.default = "openai-codex/test-override";
                }
              ];
            };
          in
          assert builtins.elem omp.packages.${system}.default evaluated.config.home.packages;
          assert evaluated.config.home.activation ? ompConfig;
          assert evaluated.config.home.file ? ".omp/agent/AGENTS.md";
          assert evaluated.config.programs.omp.settings.modelRoles.default == "openai-codex/test-override";
          assert evaluated.config.programs.omp.settings.error.notify == "on";
          pkgs.runCommand "omp-nix-module" { } "touch $out";
      };

      formatter.${system} = pkgs.writeShellApplication {
        name = "omp-nix-fmt";
        runtimeInputs = [
          pkgs.findutils
          pkgs.nixfmt
        ];
        text = ''
          if (( $# == 0 )); then
            find . -type f -name '*.nix' -not -path './.git/*' -exec nixfmt {} +
          else
            exec nixfmt "$@"
          fi
        '';
      };
    };
}
