# `fool/`：Home Manager 模块

本目录定义用户态配置，统一挂在 `fool.*` 命名空间下。`default.nix` 是聚合入口，负责导入子模块、设置 Home Manager 基线，以及计算共享的代理地址。

- 各功能模块通常在 `fool/<name>/default.nix` 中声明 option，并用 `mkIf` 按主机启用。
- `desktop/` 将通用桌面应用、大型应用与独立程序配置分为三个显式开关。
- `bililiverecorder/` 运行固定稳定版本的 GHCR 录播容器，并提供标签更新脚本。
- `reasonix/` 打包固定版本的 x86_64 Linux CLI，并提供稳定版更新脚本。
- 主机侧开关集中在 `home/<profile>/default.nix`，不要在聚合入口硬编码某台机器的选择。
- 代理端点唯一来源是 `os/homelab`（经集成模式 `osConfig` 只读）；Home 侧只保留
  `fool.proxy.use-pi` 的 profile 选择，不复制 host/URL。
- 外部 flake package（hobob、cp-guard）由模块声明 `package` option、在启用点显式传入
  input 的当前架构 package，不使用全局 overlay。
