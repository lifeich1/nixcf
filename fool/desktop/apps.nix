{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.desktop.apps;
in
{
  options.fool.desktop.apps.enable = mkEnableOption "common desktop applications and tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # web
      qbittorrent
      yt-dlp
      lux
      baidupcs-go # pan.baidu

      # productivity and development
      imagemagick
      syncthingtray
      jekyll
      usbimager
      graphviz
      gh
      onefetch # git repo summary
      kalker # math eval
      hexyl # Command-line hex viewer
      gitnr # git ignores templates
      android-tools
      bubblewrap

      # system
      python3
      appimage-run
      wl-clipboard
      kdePackages.qttools
      parted # disk util
      dysk # df
      xcp # new age cp
      bandwhich # network
      libnotify # notify-send

      # nix
      nix-update
    ];
  };
}
