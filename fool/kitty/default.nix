{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.kitty;
in
{
  options.fool.kitty = {
    enable = mkEnableOption "kitty";
    font-size = mkOption {
      type = types.int;
      default = 15;
      description = "kitty terminal font size";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.nerd-fonts; [
      fira-code
    ];

    programs.kitty = {
      enable = true;
      font = {
        size = cfg.font-size;
        name = "FiraCode Nerd Font";
      };
      settings = {
        background_opacity = 0.85;
        enable_audio_bell = "no";
        visual_bell_duration = 1;
      };
      shellIntegration.enableZshIntegration = true;
    };

  };
}
