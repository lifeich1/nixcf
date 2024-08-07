# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  pkgs-stable,
  lib,
  all_proxy ? false,
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

  #networking.hostName = "nixos-xps13"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  #networking.proxy.default = if all_proxy then "socks5h://192.168.31.142:10809" else "";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # Enable sound with pipewire.
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  fool.secrets.pass = "xps-pass";

  users.users.fool = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.xps-pass.path;
    description = "lintd";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages =
      (with pkgs; [
        git
        kate
        xsel
      ])
      ++ (with pkgs-stable; [
        firefox
        thunderbird
      ]);
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (
    with pkgs;
    [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      btop
      xray
      libsForQt5.bluedevil
      libsForQt5.bluez-qt
      libsForQt5.kwidgetsaddons
      dmidecode
    ]
  );

  fool.proxy = {
    has-pi = true;
    use-pi = false;
  };
  fool.sudo.nopass = true;
  services.xray.enable = true;
  fool.syncthing.enable = true;
}
