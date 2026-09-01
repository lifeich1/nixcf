# `nixos-pi4b`

Raspberry Pi 4B homelab 主机，架构为 `aarch64-linux`，用户为 `pi`。

- `configuration.nix`：主机特有的 initrd、kernel parameters、RTC overlay、文件系统、用户 SSH，以及 Gitea、Hobob、Xray、Attic、vlmcsd 等开关。
- Raspberry Pi 内核和 extlinux 默认值由 `flake.nix` 导入的 nixos-hardware Pi4 board profile 提供；firmware activation 保持关闭。
- `ds3231.dts`：DS3231 RTC 的 device-tree overlay，由 `configuration.nix` 引用。
- Attic 服务端环境文件由 Agenix 管理（`secrets/atticd-env.age`，仅 Pi host key 可解密），运行时位于 `/run/agenix/atticd-env`；本主机不再存放明文 `atticd.env`。
- Home Manager profile：`home/micro-srv/`；部署入口：`just pi`。
