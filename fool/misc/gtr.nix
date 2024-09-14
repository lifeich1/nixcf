{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.misc;
in
{
  options.fool.misc = {
    gtr = mkEnableOption "enable gtr collection.";
  };

  config = mkIf cfg.gtr {
    fool.misc.nixbuild = true;

    home.packages = with pkgs; [
      # (multi)media
      vlc
      calibre

      # talent
      krita
      guitarix
      libsForQt5.kdenlive
      glaxnimate # dep by kdenlive

      # web
      qbittorrent
      google-chrome
      tor-browser
      yt-dlp
      lux

      # productivity
      #hugo # static site generator
      #glow # markdown previewer in terminal
      imagemagick
      wpsoffice-cn
      syncthingtray
      jekyll
      usbimager
      graphviz

      # system
      python3
      appimage-run

      # KDE
      libsForQt5.plasma-integration
      libsForQt5.plasma-browser-integration
      libsForQt5.ktimer
      libsForQt5.kdeplasma-addons
    ];
  };
}
