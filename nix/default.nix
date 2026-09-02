{
  contextMode,
  omp,
  ompPackage,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  contextModeActivation = pkgs.writeShellScript "activate-omp-context-mode" ''
    set -euo pipefail

    mcp_config="$HOME/.omp/agent/mcp.json"
    plugin_config="$HOME/.omp/plugins/package.json"
    empty_json=${pkgs.writeText "omp-empty.json" "{}"}

    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.omp/agent" "$HOME/.omp/plugins"

    mcp_tmp=""
    plugin_tmp=""
    cleanup() {
      [[ -z "$mcp_tmp" ]] || ${pkgs.coreutils}/bin/rm -f "$mcp_tmp"
      [[ -z "$plugin_tmp" ]] || ${pkgs.coreutils}/bin/rm -f "$plugin_tmp"
    }
    trap cleanup EXIT

    mcp_source="$mcp_config"
    if [[ ! -f "$mcp_source" ]]; then
      mcp_source="$empty_json"
    fi
    mcp_tmp="$(${pkgs.coreutils}/bin/mktemp "$HOME/.omp/agent/.mcp.json.XXXXXX")"
    ${pkgs.jq}/bin/jq \
      --arg command "${lib.getExe contextMode}" \
      --arg data_dir "${config.home.homeDirectory}/.omp/context-mode" '
      .mcpServers = (.mcpServers // {}) |
      .mcpServers["context-mode"] = {
        type: "stdio",
        command: $command,
        env: {
          CONTEXT_MODE_PLATFORM: "omp",
          CONTEXT_MODE_DIR: $data_dir
        }
      }
    ' "$mcp_source" > "$mcp_tmp"
    ${pkgs.coreutils}/bin/chmod 600 "$mcp_tmp"
    ${pkgs.coreutils}/bin/mv -f "$mcp_tmp" "$mcp_config"
    mcp_tmp=""

    plugin_source="$plugin_config"
    if [[ ! -f "$plugin_source" ]]; then
      plugin_source="$empty_json"
    fi
    plugin_tmp="$(${pkgs.coreutils}/bin/mktemp "$HOME/.omp/plugins/.package.json.XXXXXX")"
    ${pkgs.jq}/bin/jq --arg source "file:${contextMode}" '
      .name = (.name // "omp-plugins") |
      .private = true |
      .dependencies = (.dependencies // {}) |
      .dependencies["context-mode"] = $source
    ' "$plugin_source" > "$plugin_tmp"
    ${pkgs.coreutils}/bin/chmod 600 "$plugin_tmp"
    ${pkgs.coreutils}/bin/mv -f "$plugin_tmp" "$plugin_config"
    plugin_tmp=""

    trap - EXIT
  '';
in
{
  imports = [ omp.homeManagerModules.default ];

  config = lib.mkIf config.programs.omp.enable {
    programs.omp.package = lib.mkDefault ompPackage;

    programs.omp.settings = {
      setupVersion = lib.mkDefault 2;

      # Keep discovery isolated to mostly native OMP sources and OMP-installed plugins.
      disabledProviders = lib.mkDefault [
        "agent-plugins"
        "agents"
        "claude"
        "claude-plugins"
        "cline"
        "codex"
        "cursor"
        "gemini"
        "github"
        "mcp-json"
        "opencode"
        "ssh-json"
        "vscode"
        "windsurf"
      ];

      modelRoles.default = lib.mkDefault "openai-codex/gpt-5.6-sol";
      defaultThinkingLevel = lib.mkDefault "high";

      startup = {
        quiet = lib.mkDefault true;
        checkUpdate = lib.mkDefault false;
        changelogMode = lib.mkDefault "summary";
      };
      symbolPreset = lib.mkDefault "nerd";
      composer.shape = lib.mkDefault "claude";
      theme = {
        dark = lib.mkDefault "dark";
        light = lib.mkDefault "light";
      };
      statusLine = {
        preset = lib.mkDefault "default";
        separator = lib.mkDefault "pipe";
        sessionAccent = lib.mkDefault true;
        compactThinkingLevel = lib.mkDefault true;
      };
      terminal.showProgress = lib.mkDefault true;
      tui = {
        tight = lib.mkDefault false;
        resizeScrollback = lib.mkDefault "append";
        textSizing = lib.mkDefault true;
        hyperlinks = lib.mkDefault "always";
      };
      display = {
        shimmer = lib.mkDefault "classic";
        showTokenUsage = lib.mkDefault true;
        showTurnTime = lib.mkDefault true;
      };

      hideThinkingBlock = lib.mkDefault false;
      proseOnlyThinking = lib.mkDefault true;
      steeringMode = lib.mkDefault "one-at-a-time";

      tools.approvalMode = lib.mkDefault "yolo";
      bash = {
        enabled = lib.mkDefault true;
        direnv = lib.mkDefault "off";
      };
      eval.py = lib.mkDefault false;
      python.kernelMode = lib.mkDefault "session";
      goal.enabled = lib.mkDefault false;
      task.eager = lib.mkDefault "default";

      dev.autoqaConsent = lib.mkDefault "granted";
      checkpoint.enabled = lib.mkDefault true;
      github.enabled = lib.mkDefault true;
      read.renderMarkdown = lib.mkDefault true;
      memory.backend = lib.mkDefault "off";
      treeFilterMode = lib.mkDefault "default";
      marketplace.autoUpdate = lib.mkDefault "off";
      features.unexpectedStopDetection = lib.mkDefault "mechanical";
      completion.notify = lib.mkDefault "on";
      error.notify = lib.mkDefault "on";
      ask.notify = lib.mkDefault "on";
    };
    home.packages = [ contextMode ];

    home.file = {
      ".omp/plugins/node_modules/context-mode".source = contextMode;
      ".omp/agent" = {
        source = ../omp;
        recursive = true;
      };
    };

    # Preserve unrelated entries while refreshing the pinned Context Mode paths.
    home.activation.ompContextMode = {
      before = [ ];
      after = [ "writeBoundary" ];
      data = "run ${contextModeActivation}";
    };

  };
}
