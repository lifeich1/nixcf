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
    #services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.xkb = {
      layout = "cn";
      variant = "";
    };

    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
      # KDE
      #libsForQt5.plasma-framework
      #libsForQt5.frameworkintegration
      #libsForQt5.kwidgetsaddons
    ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          kdePackages.fcitx5-chinese-addons
          #fcitx5-rime
          #fcitx5-lua
        ];
      };
    };
  };
}
