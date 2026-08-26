# XPS13 Home profile

`default.nix` 是 `nixos-xps13` 的 Home Manager 入口。它启用桌面工具集合、Cargo 镜像、代理 Git/SSH、Zsh、Neovim LSP，以及小字号 Alacritty。

与 `home/pc` 相比不启用录播、cp-guard、Neovim AI、WezTerm 和 Attic watch-store。系统硬件/服务配置在 `host/nixos-xps13/`。
