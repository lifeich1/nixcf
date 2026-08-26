# Pi4B Home profile

`default.nix` 是 `nixos-pi4b` 用户 `pi` 的最小 Home Manager 入口：安装 GPIO/I²C 工具，启用 Zellij、Zsh、GitHub 代理、Vultr SSH 别名和 Fastfetch 配置。

`fastfetch-config.jsonc` 是该主机专用展示配置。服务端应用与硬件设置分别位于 `os/` 和 `host/nixos-pi4b/`。
