{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.desktop.programs;
in
{
  options.fool.desktop.programs.enable = mkEnableOption "desktop program configuration";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
    };
    programs.thunderbird = {
      # TODO add accounts through accounts.email.accounts
      enable = true;
      profiles.fool = {
        isDefault = true;
        settings."font.language.group" = "zh-CN";
      };
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = true;
    };
  };
}
