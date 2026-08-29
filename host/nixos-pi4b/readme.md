# `nixos-pi4b`

Raspberry Pi 4B homelab 主机，架构为 `aarch64-linux`，用户为 `pi`。

- `configuration.nix`：主机特有的 initrd、kernel parameters、RTC overlay、文件系统、用户 SSH，以及 Gitea、Hobob、Xray、Attic、vlmcsd 等开关。
- Raspberry Pi 内核和 extlinux 默认值由 `flake.nix` 导入的 nixos-hardware Pi4 board profile 提供；firmware activation 保持关闭。
- `ds3231.dts`：DS3231 RTC 的 device-tree overlay，由 `configuration.nix` 引用。
- `atticd.env`：主机侧 Attic 环境文件；另有 `os/atticd/atticd.env`，修改前先确认实际引用链。
- Home Manager profile：`home/micro-srv/`；部署入口：`just pi`。
