# 运维辅助脚本

本目录放不适合直接写入 Nix module 的便携运维工具。

- `deploy-guard.sh`：deploy 前的 clean-tree guard，被 `justfile` 的通用
  `deploy-host` recipe 调用；对应测试在 `tests/deploy-guard.t`。
- 临时调整 nix-daemon 代理使用根 `justfile` 的 `proxy`/`no-proxy` recipe
  （经 `/run/systemd/system` drop-in，mktemp + trap 保证恢复），不再直接改写
  `/etc/nix/nix.conf`。代理端口与 deploy target 分别来自
  `homelabEndpoints`、`deployTargets` flake output，不要在本目录复制端口字符串。
