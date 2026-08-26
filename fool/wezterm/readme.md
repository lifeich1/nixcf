# WezTerm

`default.nix` 提供 `fool.wezterm.enable` 与 `font-size`，安装 FiraCode Nerd Font、启用 Zsh integration，并读取 `cfg.lua` 生成最终配置。

动态值由 Nix 在 `cfg.lua` 后追加并传给 `Wrap`；因此 Lua 文件必须继续暴露兼容的 `Wrap` 函数。
