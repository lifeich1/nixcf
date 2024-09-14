{ config, lib, ... }:
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
    nixgl-wrapper = mkEnableOption "command `nixgl-alacritty` & desktop entry";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.zellij.enable = true;

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
              family = "MesloLGS NF";
            };
          };
        };
      };
    })
    (mkIf cfg.nixgl-wrapper {
      home.packages = [
        (
          let
            nixglil = inputs.nixgl.packages."${system}".nixGLIntel;
            pack = [
              nixglil
              pkgs.alacritty
            ];
          in
          pkgs.runCommand "nixgl-alacritty"
            {
              buildInputs = pack;
              nativeBuildInputs = [ pkgs.makeWrapper ];
            }
            ''
              mkdir -p $out/bin/
              ln -s ${nixglil}/bin/nixGLIntel $out/bin/nixgl-alacritty
              wrapProgram $out/bin/nixgl-alacritty --add-flags alacritty
            ''
        )
      ];
      xdg.desktopEntries.nixgl-alacritty = {
        name = "nixgl Wrapped alacritty";
        exec = "nixgl-alacritty";
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };
    })
  ];
}
