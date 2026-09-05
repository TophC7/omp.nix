{
  b2n,
  lib,
  omp,
  pkgs,
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  upstreamPackage = omp.packages.${system}.default;
  upstreamBunPackages = pkgs.callPackage (omp.outPath + "/nix/bun.nix") { };
  missingKdl = !builtins.hasAttr "@bgotink/kdl@0.4.0" upstreamBunPackages;
  kdlBunDeps = b2n.fetchBunDeps {
    bunNix = ./locks/omp-kdl-bun.nix;
  };
in
upstreamPackage.overrideAttrs (old: {
  # Upstream bun.lock added KDL before its generated bun.nix caught up.
  bunDeps =
    if missingKdl then
      pkgs.symlinkJoin {
        name = "omp-bun-cache";
        paths = [
          old.bunDeps
          kdlBunDeps
        ];
      }
    else
      old.bunDeps;
  bunInstallFlags = lib.unique ((old.bunInstallFlags or [ ]) ++ [ "--offline" ]);
})
