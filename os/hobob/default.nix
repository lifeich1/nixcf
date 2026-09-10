# Hobob 系统服务
#
# `default.nix` 声明 `fool.hobob.enable` 与 `fool.hobob.package`：启用时以
# `dataDir`（Pi 上为 /home/pi/hub/hobob）为工作目录运行专用用户 `hobob`。
#
# package 由启用点（`host/nixos-pi4b/configuration.nix`）显式传入
# `inputs.hobob.packages.${pkgs.stdenv.hostPlatform.system}.default`，不再通过
# overlay 注入隐式 `pkgs.hobob`。
#
# 运行时数据迁移（停服 → 备份 → 目录属主/权限 → 启动验证）属于部署序列
# （refactor-plan-04 阶段 6），本模块只声明目标态。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.hobob;
in
{
  options.fool.hobob = {
    enable = mkEnableOption "hobob service（原 sys-service）";
    openFirewall = mkEnableOption "open hobob port tcp:3731 (LAN access)";
    package = mkOption {
      type = types.package;
      description = "hobob package（由启用点显式传入当前架构的 input package）";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/opt/hobob";
      description = ''
        hobob 工作目录与资源位置。Pi 现场核查：资源本体在 /home/pi/hub/hobob
        （/opt/hobob 下 assets/static/templates 是指向它的 symlink，.cache 留在
        /opt/hobob）。不要把资源搬到 /var/lib/hobob。
      '';
    };
    port = mkOption {
      type = types.port;
      default = 3731;
      description = "hobob 监听端口（firewall 规则用；程序固定监听全接口）";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # unit 名保留历史值 `programs-hobob`（2026-09-10 决策）：改名会变更 unit 名并
      # 影响既有部署/日志/依赖，属于部署序列动作，不在本地收尾中执行。
      systemd.services."programs-hobob" = {
        description = "Autostart hobob";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "hobob";
          Group = "hobob";
          WorkingDirectory = cfg.dataDir;
          StateDirectory = "hobob";
          ExecStart = lib.getExe' cfg.package "hobob";
          # 部署验证程序写路径后再增量加 hardening（refactor-plan-04 阶段 6）；
          # 现场核查只观察到写 dataDir/.cache。
        };
      };
      users.users.hobob = {
        isSystemUser = true;
        group = "hobob";
        description = "hobob service user";
      };
      users.groups.hobob = { };
    })
    # Hobob 监听 3731（见现场核查），规则由本 module 拥有；
    # 收紧宽范围（refactor-plan-04 阶段 3）前须由 host 显式开启。
    (mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })
  ];
}
