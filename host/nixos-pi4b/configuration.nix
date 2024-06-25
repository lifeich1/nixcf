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

  # TODO pack as mod in future
  services.atticd = {
    enable = true;
    credentialsFile = "/etc/fool/attic/atticd.env";
    settings = {
      listen = "[::]:8080";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };

      garbage-collection.default-retention-period = "6 months";
    };
  };
  environment.etc."fool/attic/atticd.env".source = ./atticd.env; # homelab only, secret expose ok

}
