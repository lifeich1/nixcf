{
  pkgs,
  username,
  adminKeys,
  inputs,
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

  fool.hobob = {
    package = inputs.hobob.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enable = true;
    openFirewall = true; # hobob tcp:3731 LAN
    # 资源本体位置（现场核查）；目录属主/可读性调整在部署序列执行
    dataDir = "/home/pi/hub/hobob";
  };
  # Pi 本机解析 my-pi 到 loopback 由 networking.extraHosts 维护，不注入共享 LAN hosts 条目
  fool.homelab.pi.resolvable = false;
  services.xray.enable = true;
  # gtr7（fool.homelab.proxy.use-pi=true）经 SOCKS TCP 走 Pi 的 xray 10809 出网
  #（os/proxychains + fool.proxy）；收紧后必须放行此入站。UDP 10809 无消费方不开。
  # xray 无系统 service module，规则由 Pi host 单一拥有（见 os/firewall/readme.md）。
  networking.firewall.allowedTCPPorts = [ 10809 ];
  fool.gitea = {
    enable = true;
    openFirewall = true; # gitea tcp:3000 LAN
    migrationProxy = true; # GitHub migration 经 127.0.0.1:10819
  };
  fool.vlmcsd = {
    enable = true;
    openFirewall = true; # KMS tcp:1688 LAN
  };
  fool.atticd = {
    enable = true;
    openFirewall = true; # atticd tcp:8080（gtr7/xps13 substituter）
  };
}
