# Bilibili Live Recorder：Home Manager Podman 容器。
#
# `fool.bililiverecorder.enable` 控制容器；image 默认由 `source.json` 的固定版本派生
#（update-bililiverecorder 原子管理），dataDir/端口/访问策略为显式 options
#（refactor-plan-04 阶段 8）。容器跑在 GTR7(x86_64)，firewall 未放行 LAN（仅本机）。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.bililiverecorder;
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
{
  options.fool.bililiverecorder = {
    enable = mkEnableOption "bililiverecorder (contained app)";
    image = mkOption {
      type = types.str;
      default = "ghcr.io/bililiverecorder/bililiverecorder:${source.version}";
      description = "容器镜像（默认 source.json 固定版本；可用 digest 覆盖）";
    };
    dataDir = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/公共/bilirec";
      description = "录制数据目录（挂载到容器 /rec）";
    };
    hostPort = mkOption {
      type = types.port;
      default = 2356;
      description = "宿主监听端口（容器内固定 2356，映射字符串由 module 生成）";
    };
    openAccess = mkOption {
      type = types.bool;
      default = true;
      description = "BREC_HTTP_OPEN_ACCESS（HTTP 无鉴权开放访问）";
    };
  };

  config = mkIf cfg.enable {
    services.podman.enable = true;
    services.podman.containers.bililiverecorder = {
      inherit (cfg) image;
      # user = config.home.username;
      ports = [ "${toString cfg.hostPort}:2356" ];
      volumes = [ "${cfg.dataDir}:/rec" ];
      environment = {
        BREC_HTTP_OPEN_ACCESS = if cfg.openAccess then "1" else "0";
      };
    };
  };
}
