# KDE Plasma

`default.nix` 通过 `fool.plasma.enable` 配置 Plasma 6、Wayland SDDM、KDE Connect、fcitx5 中文输入法和所需字体。

它还为 Calibre 添加 Wayland/X11 wrapper overlay。通常由 `os/collections/gtr.nix` 间接启用，不应在 host 中重复配置桌面栈。
