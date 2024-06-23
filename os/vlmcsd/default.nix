{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.vlmcsd;
in
{
  options.fool.vlmcsd = {
    enable = mkEnableOption "vlmcsd";
  };

  config = mkIf cfg.enable {
    virtualisation.podman.enable = true;
    systemd.services."podman-vlmcsd" = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        https_proxy = "socks5://127.0.0.1:10809";
      };
      script =
        "${pkgs.podman}/bin/podman run "
        + "-p 1688:1688 --name vlmcsd --replace "
        + "docker.io/mikolatero/vlmcsd:latest";
    };
    networking = {
      firewall = {
        allowedTCPPorts = [
          1688 # vlmcsd
        ];
      };
    };
  };
}
