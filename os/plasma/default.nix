{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.plasma;
in
{
  options.fool.plasma = {
    enable = mkEnableOption "plasma desktop";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    services.xserver.xkb = {
      layout = "cn";
      variant = "";
    };

    programs.kdeconnect.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs.kdePackages; [
          fcitx5-chinese-addons
        ];
      };
    };

    environment.systemPackages = with pkgs.nur.repos.rewine; [
      ttf-wps-fonts # for wps
      ttf-ms-win10 # for wps
    ];

    # FIX calibre ebook-viewer env, see also https://discussion.fedoraproject.org/t/calibre-and-wayland/100384/3
    nixpkgs.overlays = [
      (final: prev: {
        calibre =
          pkgs.runCommand "calibre-wayland"
            {
              buildInputs = [ prev.calibre ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
            }
            ''
              mkdir -p $out/bin/
              ln -s ${prev.calibre}/bin/calibre $out/bin/calibre
              wrapProgram $out/bin/calibre --prefix QT_QPA_PLATFORM : xcb
              ln -s ${prev.calibre}/share $out/share
            '';
      })
    ];
  };
}
