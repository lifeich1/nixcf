# Alacritty

`default.nix` 提供 `fool.alacritty.enable` 与 `font-size`。启用后安装 Hack Nerd Font、配置透明度/最大化窗口；Zellij 由 profile 显式启用（`programs.zellij.enable`），本模块不再隐式打开。

由 `home/pc` 和 `home/lightpad` 启用；终端行为变更应优先通过 option 暴露，避免写入主机 profile。
