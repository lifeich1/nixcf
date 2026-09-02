# `home/`：主机用户配置入口

本目录只描述“某类主机启用哪些 Home Manager 功能”；模块实现位于 `fool/`。

- `pc/`：GTR7 的完整桌面 profile。
- `lightpad/`：XPS13 的轻量桌面 profile。
- `micro-srv/`：Pi4B 的最小无头 profile。
- `desktop-common.nix`：GTR7 与 XPS13 共同导入的桌面用户态基线，包括 x86_64 Linux 的 Reasonix CLI。

根目录 `hosts.nix` 是主机元数据唯一来源，`flake.nix` 据此选择 profile，并把 `username`、
`inputs` 等参数传给 Home Manager。Home 的代理端点来自 `os/homelab`（经集成模式
`osConfig` 只读），Home 侧只保留 `fool.proxy.use-pi` 的 profile 选择。新增功能时先在
`fool/` 定义 option；桌面通用开关及其明确依赖放入 `desktop-common.nix`，大型应用等
主机选择留在对应 profile。
