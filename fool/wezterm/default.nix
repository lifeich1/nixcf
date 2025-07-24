{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.wezterm;
in
{
  options.fool.wezterm = {
    enable = mkEnableOption "wezterm";
    font-size = mkOption {
      type = types.int;
      default = 11;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.nerd-fonts; [
      fira-code
    ];

    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig =
        (builtins.readFile ./cfg.lua)
        + ''
          cfg.font_size = ${builtins.toString cfg.font-size}
          return cfg
        '';
    };
  };
}
