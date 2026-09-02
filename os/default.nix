{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.proxy;
in
{
  imports = [
    ./access
    ./atticd
    ./base
    ./collections
    ./firewall
    ./gitea
    ./hobob
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

  config = mkIf cfg.has-pi {
    networking.hosts."192.168.3.6" = [ "my-pi" ];
  };
}
