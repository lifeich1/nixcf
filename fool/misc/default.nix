{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  _cfg = config.fool.misc;
in
{
  imports = [
    ./nixbuild.nix
    ./gtr.nix
  ];

  config = {
    # basic
    home.packages = with pkgs; [
      # utils
      ripgrep # recursively searches directories for a regex pattern
      #jq # A lightweight and flexible command-line JSON processor
      #yq-go # yaml processer https://github.com/mikefarah/yq
      eza # A modern replacement for ‘ls’
      just
      fd # modern `find`
      skim
      nnn

      # networking tools
      mtr # A network diagnostic tool
      iperf
      dnsutils # `dig` + `nslookup`
      #ldns # replacement of `dig`, it provide the command `drill`
      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      ipcalc # it is a calculator for the IPv4/v6 addresses
      inetutils # ping6 etc.

      # archives
      zip
      xz
      unzip
      p7zip

      # misc
      emojify
      #cowsay
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      #gnupg
      #busybox
      psmisc

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb
      btop # replacement of htop/nmon
      #iotop # io monitoring
      #iftop # network monitoring

      # system call monitoring
      #strace # system call monitoring
      #ltrace # library call monitoring
      lsof # list open files
    ];
  };
}
