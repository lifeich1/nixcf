{
  config,
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
    # KMS 1688 供 LAN 客户端访问，规则由本 module 拥有；host 显式开启。
    openFirewall = mkEnableOption "open vlmcsd port tcp:1688 (LAN access)";
    image = mkOption {
      type = types.str;
      # pin 到 2026-09-08 验证的 OCI index digest（含 linux/arm64 + amd64 manifest，
      # registry 查询确认；切换前在 Pi/aarch64 pull 验证）。
      default = "docker.io/mikolatero/vlmcsd@sha256:aadb2a388754691687bc040f13a18bfc787ff67b1d0fcebf171f5361f54a5d0c";
      description = "vlmcsd container image（默认固定 digest，避免 latest 漂移）";
    };
    port = mkOption {
      type = types.port;
      default = 1688;
      description = "vlmcsd host/container 端口（映射字符串由 module 生成）";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
      virtualisation.oci-containers.containers."vlmcsd" = {
        image = cfg.image;
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
      };
    })
    (mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })
  ];
}
