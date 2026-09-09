# XPS13 Home profile

`default.nix` 是 `nixos-xps13` 的 Home Manager 入口。它导入 `home/desktop-common.nix` 提供桌面工具集合、Reasonix CLI、kdocs CLI/skill、Cargo 镜像、代理 Git/SSH、Zsh 和 Neovim LSP，并只在本文件设置小字号 Alacritty。

为保证本次结构重构前后等价，它暂时显式保留大型桌面应用；后续精简应单独评估。与 `home/pc` 相比不启用录播、cp-guard、Neovim AI、WezTerm 和 Attic watch-store。系统硬件/服务配置在 `host/nixos-xps13/`。
