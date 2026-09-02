# 系统基础：locale、时区、基础工具、默认编辑器与 OpenSSH daemon。
{ pkgs, lib, ... }:
with lib;
{
  # 引导默认：systemd-boot 保留最近 50 个条目
  boot.loader.systemd-boot.configurationLimit = mkDefault 50;

  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  programs.zsh.enable = true;
  services.openssh.enable = true;
}
