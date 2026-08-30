{
  contextMode,
  homeManagerModule,
  omp,
  ompPackage,
  pkgs,
}:
let
  system = pkgs.stdenv.hostPlatform.system;
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
in
{
  omp = ompPackage;
  context-mode = contextMode;
  module =
    assert evaluated.config.programs.omp.package != omp.packages.${system}.default;
    assert builtins.elem evaluated.config.programs.omp.package evaluated.config.home.packages;
    assert evaluated.config.home.activation ? ompConfig;
    assert evaluated.config.home.activation ? ompContextMode;
    assert evaluated.config.home.file ? ".omp/plugins/node_modules/context-mode";
    assert evaluated.config.home.file ? ".omp/agent";
    assert evaluated.config.programs.omp.settings.modelRoles.default == "openai-codex/test-override";
    assert evaluated.config.programs.omp.settings.error.notify == "on";
    pkgs.runCommand "omp-nix-module" { } "touch $out";
}
