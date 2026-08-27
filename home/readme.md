# `home/`：主机用户配置入口

本目录只描述“某类主机启用哪些 Home Manager 功能”；模块实现位于 `fool/`。

- `pc/`：GTR7 的完整桌面 profile。
- `lightpad/`：XPS13 的轻量桌面 profile。
- `micro-srv/`：Pi4B 的最小无头 profile。
- `desktop-common.nix`：GTR7 与 XPS13 共同导入的桌面用户态基线。

根 `flake.nix` 的 `hosts` 清单选择 profile，`mkHost` 把 `username`、`device`、inputs 等参数传给 Home Manager。新增功能时先在 `fool/` 定义 option；桌面通用开关及其明确依赖放入 `desktop-common.nix`，大型应用等主机选择留在对应 profile。
