{
  description = "omp.nix - Toph's Oh My Pi configuration";

  inputs = {
    omp.url = "github:can1357/oh-my-pi";
    nixpkgs.follows = "omp/nixpkgs";
    bun2nix.follows = "omp/bun2nix";

    context-mode = {
      url = "github:mksglu/context-mode/v1.0.169";
      flake = false;
    };
  };

  outputs =
    {
      bun2nix,
      context-mode,
      self,
      nixpkgs,
      omp,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = package: nixpkgs.lib.getName package == "context-mode";
      };
      b2n = bun2nix.packages.${system}.default;
      contextMode = pkgs.callPackage ./nix/context-mode.nix {
        inherit b2n;
        src = context-mode;
      };
      ompPackage = pkgs.callPackage ./nix/omp.nix {
        inherit b2n omp pkgs;
      };
      homeManagerModule = import ./nix {
        inherit contextMode omp ompPackage;
      };
      ompApp = omp.apps.${system}.omp // {
        program = "${ompPackage}/bin/omp";
      };
    in
    {
      homeManagerModules = {
        omp = homeManagerModule;
        default = self.homeManagerModules.omp;
      };

      packages.${system} = {
        omp = ompPackage;
        context-mode = contextMode;
        default = ompPackage;
      };

      apps.${system} = {
        omp = ompApp;
        default = ompApp;
      };

      checks.${system}.module = pkgs.callPackage ./nix/checks.nix {
        inherit
          contextMode
          homeManagerModule
          ompPackage
          ;
      };

      formatter.${system} = pkgs.callPackage ./nix/formatter.nix { };
    };
}
