# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs-stable,
  pkgs,
  lib,
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

  # for pi4b remote deploy
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  ## NOTE hardware above, userspace below

  fool.sudo.nopass = true;
  fool.secrets.pass = "gtr-pass";

  users.users.fool = {
    isNormalUser = true;
    description = "fool-gtr5";
    extraGroups = [
      "networkmanager"
      "wheel"
      "vboxusers"
      "jackaudio"
      "audio"
    ];
    shell = pkgs.zsh;
  };

  fool.collections.gtr = true;
  fool.proxy.has-pi = true;
  services.xray.enable = true;
  fool.syncthing.enable = true;
  fool.virtualbox.enable = true;

  # NOTE experiment
  services.teamviewer.enable = true;
}
