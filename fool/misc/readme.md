# 用户工具集合

`default.nix` 无条件安装通用 CLI、网络、归档和系统诊断工具，并导入一个可选扩展：

- `nixbuild.nix`：`fool.misc.nixbuild`，Nix 构建、检查和空间分析工具。

桌面应用和程序配置已移至 `fool/desktop/`。通用小型 CLI 才放本目录的无条件集合；Nix 工具由主机 profile 显式启用。
