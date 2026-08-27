# 桌面应用与程序配置

`default.nix` 聚合三个相互独立的可选模块：

- `fool.desktop.apps.enable`：桌面通用应用、开发辅助和系统工具。
- `fool.desktop.heavy-apps.enable`：完整桌面使用的大型远程、多媒体、创作和办公应用。
- `fool.desktop.programs.enable`：Firefox、Thunderbird、zoxide 与 tealdeer 的 Home Manager 配置。

这些开关不会隐式启用 Nix 构建工具或 Lemonade。主机 profile 必须按需显式选择 `fool.misc.nixbuild` 和 `fool.com-lemonade.enable`。
