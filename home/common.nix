{ config, pkgs, lib, username, ... }:
with lib;
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = mkDefault pkgs.pinentry-curses;
  };

  # 个人 identity 数据：Git user/email 由 profile 层提供，不在 fool/git 模块写死
  fool.git = {
    user = "lifeich1";
    email = "lifeich0@gmail.com";
  };
}