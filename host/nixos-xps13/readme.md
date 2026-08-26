# `nixos-xps13`

Dell XPS 13 9360 轻量移动主机，架构为 `x86_64-linux`，用户为 `fool`。

- `configuration.nix`：systemd-boot、用户、桌面集合、代理、Xray 与 Syncthing 开关。
- `hardware-configuration.nix`：硬件扫描结果；专用硬件优化还由 `flake.nix` 引入 `dell-xps-13-9360` 模块。
- Home Manager profile：`home/lightpad/`。
- 部署入口：`just xps`，目标地址定义在根 `justfile`。
