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

    ## rely on:
    ## nixgl = {
    ##   url = "github:nix-community/nixGL";
    ##   inputs.nixpkgs.follows = "nixpkgs";
    ## };
    # NOTE disable for reduce inputs
    #nixgl-wrapper = mkEnableOption "command `nixgl-alacritty` & desktop entry";
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
    ## NOTE use makeDesktopItem & copyDesktopItems to override package
    #(mkIf cfg.nixgl-wrapper {
    #  home.packages = with pkgs; [
    #    (
    #      writeShellApplication {
    #        name = "nixgl-alacritty";
    #        runtimeInputs =
    #          let
    #            nixglil = inputs.nixgl.packages."${system}".nixGLIntel;
    #          in [
    #            nixglil
    #            alacritty
    #          ];
    #        text = ''
    #          exec nixGLIntel alacritty
    #        '';
    #      }
    #    )
    #  ];
    #  xdg.desktopEntries.nixgl-alacritty = {
    #    name = "nixgl Wrapped alacritty";
    #    exec = "nixgl-alacritty";
    #    categories = [
    #      "System"
    #      "TerminalEmulator"
    #    ];
    #  };
    #})
  ];
}
