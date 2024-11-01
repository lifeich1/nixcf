{
  config,
  lib,
  pkgs,
  pkgs-stable,
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

    home.packages =
      (with pkgs-stable; [
        calibre # https://github.com/NixOS/nixpkgs/issues/348845
        #teamviewer # com use
      ])
      ++ (with pkgs; [
        # remote work
        rustdesk-flutter

        # (multi)media
        vlc

        # talent
        krita
        guitarix
        #libsForQt5.kdenlive # TODO
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
        gh

        # system
        python3
        appimage-run
        #xsel # TODO update to wayland tool

        # KDE TODO upgrade
        #kate
        #libsForQt5.plasma-integration
        #libsForQt5.plasma-browser-integration
        #libsForQt5.ktimer
        #libsForQt5.kdeplasma-addons
      ]);

    programs.firefox.enable = true;
    programs.thunderbird = {
      # TODO move out with config control
      enable = true;
      profiles.fool = {
        isDefault = true;
        settings = {
          "font.language.group" = "zh-CN";
        };
      };
    };
  };
}
