# GTR7 Home profile

`default.nix` 是 `nixos-gtr7` 的完整 Home Manager 入口。它导入 `home/desktop-common.nix`，并额外启用大型桌面应用、试用包、录播容器、cp-guard、AI Neovim、Ghostty、WezTerm、Attic watch-store 和 GTR7 的 Alacritty 字号。

这是新用户态功能的首要试用 profile。系统级桌面、音频和虚拟化配置在 `host/nixos-gtr7/` 与 `os/collections/gtr.nix`。
