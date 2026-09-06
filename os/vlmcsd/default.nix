{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.vlmcsd;
  image = "docker.io/mikolatero/vlmcsd:latest";
  port = "1688:1688";
in
{
  options.fool.vlmcsd = {
    enable = mkEnableOption "vlmcsd";
    # KMS 1688 供 LAN 客户端访问，规则由本 module 拥有；收紧前须由 host 显式开启。
    openFirewall = mkEnableOption "open vlmcsd port tcp:1688";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
      virtualisation.oci-containers.containers."vlmcsd" = {
        inherit image;
        ports = [ port ];
      };
    })
    (mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = [ 1688 ];
    })
  ];
}
