{ pkgs, ... }:
{
  imports = [ ../common.nix ];

  home.packages = with pkgs; [
    wiringpi
    i2c-tools
  ];

  programs.zellij.enable = true;

  fool.git.github-proxy = true;
  fool.zsh.enable = true;
  fool.fastfetch = {
    enable = true;
    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "shell"
        "display"
        "de"
        "wm"
        "wmtheme"
        "theme"
        "icons"
        "font"
        "cursor"
        "terminal"
        "terminalfont"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "localip"
        "battery"
        "poweradapter"
        "locale"
        "break"
        "colors"
      ];
    };
  };
  fool.cfg-ssh.hosts = {
    ayu = {
      hostName = "64.176.41.80";
      user = "root";
      forwardAgent = true;
    };
  };
}
