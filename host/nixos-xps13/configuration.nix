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

  fool.collections.gtr = true;
  # 系统 proxychains 保持本机；my-pi 的 hosts 解析由 fool.homelab.pi.resolvable 默认提供
  fool.homelab.proxy.use-pi = false;
  fool.sudo.nopass = true;
  services.xray.enable = true;
  fool.syncthing.enable = true;
}
