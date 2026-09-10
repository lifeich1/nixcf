# KDE Plasma

`default.nix` 通过 `fool.plasma.enable` 配置 Plasma 6、Wayland SDDM、KDE Connect、fcitx5
中文输入法和桌面字体（`ttf-ms-win10` + `sarasa-gothic`）。原与 `ttf-ms-win10` 冲突的
`ttf-wps-fonts` 已移除，WPS 使用系统字体（audit §10）。

启用时同时导入 NUR overlay（字体来源）与 Calibre 的 Wayland/X11 wrapper overlay；两者
都只在 plasma 启用时生效，Pi 等非桌面 host 不再承载 NUR module 依赖。Calibre wrapper 用
同一 overlay 的 `final` package set 重建完整包，只 wrap 入口 `calibre`。

通常由 `os/collections/desktop.nix`（`fool.collections.desktop`）间接启用，不应在 host 中
重复配置桌面栈。
