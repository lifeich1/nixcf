{
  pkgs,
  username,
  adminKeys,
  ...
}:
{

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    kernelModules = [
      "i2c-dev"
      "rtc-ds1307"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [ "iomem=relaxed" ];
  };

  # https://github.com/NixOS/nixpkgs/issues/320557
  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      overlays = [
        {
          name = "bcm2711-rpi-4-ds3231";
          dtsFile = ./ds3231.dts;
        }
      ];
    };
    i2c.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    dtc
  ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";

  # NOTE hardware above, userspace below

  networking.extraHosts = ''
    127.0.0.1  my-pi
  '';

  fool.secrets.pass = "pi-pass";

  users = {
    mutableUsers = false;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ adminKeys ];
      shell = pkgs.zsh;
    };
  };

  fool.firewall = {
    serve-hobob = true;
    serve-friedegg = true;
  };
  fool.hobob = {
    overlay = true;
    sys-service = true;
  };
  # Pi 本机解析 my-pi 到 loopback 由 networking.extraHosts 维护，不注入共享 LAN hosts 条目
  fool.homelab.pi.resolvable = false;
  services.xray.enable = true;
  fool.gitea.enable = true;
  fool.vlmcsd = {
    enable = true;
    invokeType = "nix";
  };
  fool.atticd.enable = true;
}
