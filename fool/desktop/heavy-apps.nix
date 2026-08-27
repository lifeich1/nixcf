{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.desktop.heavy-apps;
in
{
  options.fool.desktop.heavy-apps.enable =
    mkEnableOption "large applications for the full desktop profile";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # remote work
      teamviewer

      # (multi)media
      vlc
      ffmpeg

      # creative work
      krita
      guitarix
      kmetronome
      qsynth
      kdePackages.kdenlive

      # large desktop clients
      google-chrome
      tor-browser
      wpsoffice-cn
      calibre
    ];
  };
}
