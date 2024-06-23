{
  config,
  pkgs,
  username,
  gtr5_pubkey,
  ...
}:
{

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [ "iomem=relaxed" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  environment.systemPackages = with pkgs; [ raspberrypi-eeprom ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";

  # NOTE hardware above, userspace below

  fool.secrets.pass = "pi-pass";

  users = {
    mutableUsers = false;
    users."${username}" = {
      isNormalUser = true;
      hashedPasswordFile = config.age.secrets.pi-pass.path;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ gtr5_pubkey ];
      shell = pkgs.zsh;
    };
  };

  fool.hobob.overlay = true;
  fool.proxy.has-pi = false;
  services.xray.enable = true;
  fool.gitea.enable = true;
  fool.vlmcsd.enable = true;
}
