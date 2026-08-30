{
  b2n,
  lib,
  pkgs,
  src,
}:

pkgs.stdenv.mkDerivation {
  pname = "context-mode";
  version = (lib.importJSON (src + "/package.json")).version;
  inherit src;

  strictDeps = true;
  nativeBuildInputs = [
    b2n.hook
    pkgs.bun
    pkgs.makeWrapper
    pkgs.nodejs
  ];

  bunDeps = b2n.fetchBunDeps {
    bunNix = ./locks/context-mode-bun.nix;
  };

  dontUseBunBuild = true;
  dontUseBunCheck = true;
  dontUseBunInstall = true;

  bunInstallFlags = [
    "--linker=isolated"
    "--offline"
  ];

  postPatch = ''
    # Keep package.json consistent with bun.lock's optional native dependency.
    bun -e '
      const fs = require("fs");
      const packageJsonPath = "package.json";
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
      const betterSqliteVersion = packageJson.dependencies?.["better-sqlite3"];

      if (betterSqliteVersion) {
        packageJson.optionalDependencies = packageJson.optionalDependencies ?? {};
        packageJson.optionalDependencies["better-sqlite3"] = betterSqliteVersion;
        delete packageJson.dependencies["better-sqlite3"];
        fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2) + "\n");
      }
    '
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    bun run tsc
    bun -e "if (process.platform !== 'win32') require('fs').chmodSync('build/cli.js', 0o755)"
    bun run bundle
    bun run assert-bundle
    bun run assert-asymmetric-drift
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    rm -rf node_modules
    bun install --production --offline --frozen-lockfile --ignore-scripts --linker=isolated

    mkdir -p $out
    bun -e '
      const fs = require("fs");
      const path = require("path");
      const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"));

      for (const entry of ["package.json", ...packageJson.files]) {
        fs.cpSync(entry, path.join(process.env.out, entry), { recursive: true });
      }
    '
    cp -R node_modules $out/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/context-mode \
      --add-flags "$out/cli.bundle.mjs" \
      --prefix PATH : ${lib.makeBinPath [ pkgs.bun ]}
    runHook postInstall
  '';

  meta = {
    description = "Context window optimization for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.elastic20;
    mainProgram = "context-mode";
    platforms = lib.platforms.unix;
  };
}
