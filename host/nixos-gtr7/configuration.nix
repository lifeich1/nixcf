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

  # 无系统 service module、由 host 单一拥有的入站端口（见 os/firewall/readme.md
  # 端口表）。两者都只在本机对 LAN 开放，xps13 不开放：
  # - 9090/tcp：Calibre 无线设备连接 / content server（用户层 GUI 服务，
  #   calibre 运行时监听 0.0.0.0:9090）。
  # - 9119/tcp：Hermes Agent dashboard backend（仓库外用 podman-compose 常驻的
  #   容器，入口在 zsrc 的 gtr7/hermes-podman；dashboard 进程绑 0.0.0.0:9119），
  #   Hermes 客户端「Remote gateway」与手机浏览器经它连入。
  networking.firewall.allowedTCPPorts = [
    9090
    9119
  ];

  # desktop + audio + pro-audio（GTR7 有 JACK/实时工作流，拆分自 fool.collections.gtr）
  fool.collections = {
    desktop = true;
    audio = true;
    pro-audio = true;
  };
  fool.homelab.proxy.use-pi = true;
  services.xray.enable = true;
  # xray 10809 仅本机 loopback 使用，无需入站规则（calibre 9090 规则见上）。
  fool.syncthing = {
    enable = true;
    openFirewall = true; # 22000/tcp + 21027/udp（上游 services.syncthing.openFirewall）
  };
  fool.virtualbox = {
    enable = true;
    users = [ "fool" ];
  };
}
