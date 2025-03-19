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
    fool.com-lemonade.enable = true;

    home.packages = with pkgs; [
      # remote work
      rustdesk-flutter

      # (multi)media
      vlc

      # talent
      krita
      guitarix
      kmetronome
      qsynth
      kdePackages.kdenlive
      #glaxnimate # dep by kdenlive

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
      calibre

      # system
      python3
      appimage-run
      wl-clipboard
      kdePackages.qttools
      parted # disk util

      # nix
      nix-update
    ];

    programs.firefox.enable = true;
    programs.thunderbird = {
      # TODO move out with config control
      # use accounts.email.accounts.<name>.imap & accounts.email.accounts.<name>.thunderbird
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
