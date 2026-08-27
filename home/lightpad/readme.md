# XPS13 Home profile

`default.nix` 是 `nixos-xps13` 的 Home Manager 入口。它导入 `home/desktop-common.nix` 提供桌面工具集合、Cargo 镜像、代理 Git/SSH、Zsh 和 Neovim LSP，并只在本文件设置小字号 Alacritty。

与 `home/pc` 相比不启用录播、cp-guard、Neovim AI、WezTerm 和 Attic watch-store。系统硬件/服务配置在 `host/nixos-xps13/`。
