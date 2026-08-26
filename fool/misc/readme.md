# 用户工具集合

`default.nix` 无条件安装通用 CLI、网络、归档和系统诊断工具，并导入两个扩展：

- `gtr.nix`：`fool.misc.gtr`，桌面/多媒体/生产力工具和 Firefox、Thunderbird 等。
- `nixbuild.nix`：`fool.misc.nixbuild`，Nix 构建、检查和空间分析工具。

`gtr` 会自动启用 `nixbuild` 与 `fool.com-lemonade`。新增大型 GUI 包应放在 `gtr.nix`，通用小型 CLI 才放聚合入口。
