# 运维辅助脚本

本目录放不适合直接写入 Nix module 的便携运维工具。

`use-proxy.portable.sh` 用于调整 Nix daemon 的代理环境。它会涉及 systemd 和系统配置，执行前先阅读脚本并确认当前主机、代理端口及恢复方式；常规操作也可优先使用根 `justfile` 中的 `proxy`、`no-proxy` 和 `cfg-rollback` recipe。
