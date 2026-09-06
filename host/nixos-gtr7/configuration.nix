# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, username, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Syncthing 个人拓扑（folders/devices，refactor-plan-04 阶段 7）
    ../../os/syncthing/topology.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # for pi4b remote deploy
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  ## NOTE hardware above, userspace below

  fool.sudo.nopass = true;
  fool.secrets.pass = "gtr-pass";

  users.users.${username} = {
    isNormalUser = true;
    description = "fool-gtr7";
    extraGroups = [
      "networkmanager"
      "wheel"
      # vboxusers 由 fool.virtualbox.users 派生（阶段 9）
      "jackaudio"
      "audio"
    ];
    shell = pkgs.zsh;
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = username;
  services.teamviewer.enable = true;

  # Calibre 无线设备连接 / content server（用户层 GUI 服务，calibre 运行时监听
  # 0.0.0.0:9090）。无系统 service module，规则由 gtr7 host 单一拥有；仅此机对
  # LAN 设备开放，xps13 不开放（见 os/firewall/readme.md 端口表）。
  networking.firewall.allowedTCPPorts = [ 9090 ];

  # desktop + audio + pro-audio（GTR7 有 JACK/实时工作流，拆分自 fool.collections.gtr）
  fool.collections = {
    desktop = true;
    audio = true;
    pro-audio = true;
  };
  fool.homelab.proxy.use-pi = true;
  services.xray.enable = true;
  fool.syncthing = {
    enable = true;
    openFirewall = true; # 22000/tcp + 21027/udp（上游 services.syncthing.openFirewall）
  };
  fool.virtualbox = {
    enable = true;
    users = [ "fool" ];
  };
}
