{
  contextMode,
  homeManagerModule,
  ompPackage,
  pkgs,
}:
let
  evaluated = pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      {
        options = {
          home.homeDirectory = pkgs.lib.mkOption {
            type = pkgs.lib.types.str;
            default = "/home/test";
          };
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
      homeManagerModule
      {
        programs.omp.enable = true;
        programs.omp.settings.modelRoles.default = "openai-codex/test-override";
      }
    ];
  };
  config = evaluated.config;
in
assert config.programs.omp.package == ompPackage;
assert builtins.elem ompPackage config.home.packages;
assert builtins.elem contextMode config.home.packages;
assert config.home.activation ? ompConfig;
assert config.home.activation ? ompContextMode;
assert config.home.file ? ".omp/plugins/node_modules/context-mode";
assert config.home.file ? ".omp/agent";
assert config.programs.omp.settings.modelRoles.default == "openai-codex/test-override";
pkgs.runCommand "omp-nix-module" { } "touch $out"
