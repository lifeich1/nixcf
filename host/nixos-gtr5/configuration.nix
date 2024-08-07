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

  networking.networkmanager.enable = true;

  # TODO group as plasma
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # Enable sound with pipewire. FIXME debuging
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  # for guitarix
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "memlock";
      value = "8192000";
    }
    {
      domain = "*";
      type = "-";
      item = "rtprio";
      value = "95";
    }
  ];

  fool.sudo.nopass = true;
  fool.secrets.pass = "gtr-pass";

  users.users.fool = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.gtr-pass.path;
    description = "fool-gtr5";
    extraGroups = [
      "networkmanager"
      "wheel"
      "vboxusers"
      "jackaudio"
      "audio"
    ];
    packages = with pkgs; [
      firefox
      kate
      xsel
      #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    dmidecode

    # KDE
    libsForQt5.plasma-framework
    libsForQt5.frameworkintegration
    libsForQt5.kwidgetsaddons
  ];

  programs.kdeconnect.enable = true;

  fool.proxy.has-pi = true;
  services.xray.enable = true;
  fool.syncthing.enable = true;
  fool.virtualbox.enable = true;
}
