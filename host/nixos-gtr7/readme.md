# `nixos-gtr7`

AMD Ryzen 7 7840HS 主桌面，架构为 `x86_64-linux`，用户为 `fool`。

- `configuration.nix`：systemd-boot、aarch64 binfmt、用户/自动登录，以及桌面集合、Xray、Syncthing、VirtualBox 等开关。
- 入站端口由本 host 直接声明（无系统 service module）：9090/tcp Calibre、9119/tcp Hermes Agent dashboard，端口表见 `os/firewall/readme.md`。
- `hardware-configuration.nix`：自动生成的文件系统、内核模块和硬件扫描结果；除硬件变化外尽量少改。
- Home Manager profile：`home/pc/`。
- 部署入口：`just gtr7`，目标地址定义在根 `justfile`。
