# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  username,
  ...
}:

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  ## NOTE hardware above, userspace below

  fool.secrets.pass = "xps-pass";

  users.users.${username} = {
    isNormalUser = true;
    description = "lintd";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # desktop + audio + pro-audio（XPS13 有 JACK/实时工作流；拆分自 fool.collections.gtr）
  fool.collections = {
    desktop = true;
    audio = true;
    pro-audio = true;
  };
  # 系统 proxychains 保持本机；my-pi 的 hosts 解析由 fool.homelab.pi.resolvable 默认提供
  fool.homelab.proxy.use-pi = false;
  fool.sudo.nopass = true;
  services.xray.enable = true;
  # xray 10809 仅本机 loopback 使用（use-pi=false），无需入站规则。
  fool.syncthing = {
    enable = true;
    openFirewall = true; # 22000/tcp + 21027/udp（上游 services.syncthing.openFirewall）
  };
}
