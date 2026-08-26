# `home/`：主机用户配置入口

本目录只描述“某类主机启用哪些 Home Manager 功能”；模块实现位于 `fool/`。

- `pc/`：GTR7 的完整桌面 profile。
- `lightpad/`：XPS13 的轻量桌面 profile。
- `micro-srv/`：Pi4B 的最小无头 profile。

根 `flake.nix` 的 `pass_config` 选择 profile，并把 `username`、`device`、inputs 等参数传给 Home Manager。新增功能时先在 `fool/` 定义 option，再在这里按主机启用。
