# Hobob 系统服务

`default.nix` 通过 `fool.hobob.enable` 创建系统级 `programs-hobob` service，以专用系统
用户 `hobob`、`StateDirectory=hobob` 运行 `cfg.package`（`ExecStart = lib.getExe' cfg.package "hobob"`，
binary 名为 `hobob`）。

options：

- `fool.hobob.enable`：启用服务（原 `sys-service`，已改名）。
- `fool.hobob.package`：hobob package，由启用点显式传入
  （`inputs.hobob.packages.${system}.default`；**不存在** `fool.hobob.overlay`——overlay
  注入已移除，此旧描述作废）。
- `fool.hobob.dataDir`：工作目录/资源位置。Pi 现场核查（2025-09-07）：资源本体在
  `/home/pi/hub/hobob`（`/opt/hobob` 下 `assets/static/templates` 是指向它的 symlink，
  `.cache` 留在 `/opt/hobob`）；不要把资源搬到 `/var/lib/hobob`。
- `fool.hobob.port`：监听端口（默认 3731），firewall 规则使用；程序固定监听全接口。
- `fool.hobob.openFirewall`：开放 3731/tcp 入站，收紧宽范围前由 host 显式开启。

运行时迁移（停服 → 备份 `/home/pi/hub/hobob` 与 `/opt/hobob/.cache` → 目录属主/权限
调整 → 启动验证）在部署序列执行（refactor-plan-04 阶段 6），本模块只声明目标态。
