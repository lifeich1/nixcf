{ pkgs, ... }@all:
{
  home.packages = with pkgs; [
    # utils
    ripgrep # recursively searches directories for a regex pattern
    #jq # A lightweight and flexible command-line JSON processor
    #yq-go # yaml processer https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    #fzf # A command-line fuzzy finder
    skim

    # networking tools
    #mtr # A network diagnostic tool
    #iperf3
    dnsutils # `dig` + `nslookup`
    #ldns # replacement of `dig`, it provide the command `drill`
    #aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    #ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    #cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    #busybox
    psmisc

    btop # replacement of htop/nmon
    #iotop # io monitoring
    #iftop # network monitoring

    # system call monitoring
    #strace # system call monitoring
    #ltrace # library call monitoring
    lsof # list open files

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
