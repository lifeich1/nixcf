{
  config,
  pkgs,
  lib,
  device,
  gtr5_pubkey,
  ...
}:
with lib;
let
  cfg = config.fool.proxy;
in
{
  imports = [
    ./collections
    ./firewall
    ./gitea
    ./plasma
    ./proxychains
    ./sudo
    ./syncthing
    ./virtualbox
    ./vlmcsd
  ];

  options.fool.proxy = {
    has-pi = mkEnableOption "add `my-pi` to hosts";
    use-pi = mkOption {
      type = types.bool;
      default = cfg.has-pi;
      description = "enable use `my-pi` as proxy";
    };
  };

  config = mkMerge [
    {
      users.users.root.openssh.authorizedKeys.keys = [
        gtr5_pubkey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByt6QnePLW5+FE8T5dpyAOBZET7AqeE6s01Hm/rhEgq fool@nixos-xps13"
      ];
      networking.hostName = "nixos-${device}";
      nixpkgs.config.allowUnfree = true;
      time.timeZone = "Asia/Shanghai";
      i18n.defaultLocale = "zh_CN.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "zh_CN.UTF-8";
        LC_IDENTIFICATION = "zh_CN.UTF-8";
        LC_MEASUREMENT = "zh_CN.UTF-8";
        LC_MONETARY = "zh_CN.UTF-8";
        LC_NAME = "zh_CN.UTF-8";
        LC_NUMERIC = "zh_CN.UTF-8";
        LC_PAPER = "zh_CN.UTF-8";
        LC_TELEPHONE = "zh_CN.UTF-8";
        LC_TIME = "zh_CN.UTF-8";
      };
      environment.systemPackages = with pkgs; [
        vim
        wget
        git
      ];
      environment.variables.EDITOR = "vim";
      programs.zsh.enable = true;
      services.openssh.enable = true;
    }
    (mkIf cfg.has-pi {
      networking.hosts."192.168.3.6" = [ "my-pi" ];
    })
  ];
}
