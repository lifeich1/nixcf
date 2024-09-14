{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wiringpi
    i2c-tools
  ];

  programs.zellij.enable = true;

  fool.git.proxy = {
    # TODO enable at listed directories
  };
  fool.zsh.enable = true;
  fool.fastfetch.configFile = ./fastfetch-config.jsonc;
  fool.cfg-ssh = {
    vultr = true;
  };
  fool.hobob.enable = true;
}
