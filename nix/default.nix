{ omp }:
{
  config,
  lib,
  ...
}:
{
  imports = [ omp.homeManagerModules.default ];

  config = lib.mkIf config.programs.omp.enable {
    programs.omp.settings = {
      setupVersion = lib.mkDefault 2;

      modelRoles.default = lib.mkDefault "openai-codex/gpt-5.6-sol";
      defaultThinkingLevel = lib.mkDefault "high";

      startup.quiet = lib.mkDefault true;
      symbolPreset = lib.mkDefault "nerd";
      composer.shape = lib.mkDefault "claude";
      theme = {
        dark = lib.mkDefault "dark";
        light = lib.mkDefault "light";
      };
      statusLine = {
        preset = lib.mkDefault "default";
        separator = lib.mkDefault "slash";
      };
      terminal.showProgress = lib.mkDefault false;
      tui.tight = lib.mkDefault false;
      display = {
        shimmer = lib.mkDefault "classic";
        showTokenUsage = lib.mkDefault true;
        showTurnTime = lib.mkDefault true;
      };

      hideThinkingBlock = lib.mkDefault false;
      proseOnlyThinking = lib.mkDefault true;
      steeringMode = lib.mkDefault "one-at-a-time";

      tools.approvalMode = lib.mkDefault "yolo";
      bash.enabled = lib.mkDefault true;
      eval.py = lib.mkDefault false;
      python.kernelMode = lib.mkDefault "session";
      goal.enabled = lib.mkDefault false;
      task.eager = lib.mkDefault "default";

      completion.notify = lib.mkDefault "on";
      error.notify = lib.mkDefault "on";
      ask.notify = lib.mkDefault "on";
    };

    home.file.".omp/agent/AGENTS.md".source = ./SOUL.md;
  };
}
