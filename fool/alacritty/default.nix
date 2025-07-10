{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.alacritty;
in
{
  options.fool.alacritty = {
    enable = mkEnableOption "alacritty";
    font-size = mkOption {
      type = types.int;
      default = 15;
      description = "alacritty terminal font size";
    };

    # TODO option: alacritty package use config.lib.nixGL.wrap
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.zellij.enable = true;

      home.packages = with pkgs.nerd-fonts; [
        hack
      ];

      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            opacity = 0.85;
            startup_mode = "Maximized";
            dynamic_title = false;
          };
          font = {
            size = cfg.font-size;
            normal = {
              style = "Regular";
              family = "Hack Nerd Font";
            };
          };
        };
      };
    })
  ];
}
