# `fool/`：Home Manager 模块

本目录定义用户态配置，统一挂在 `fool.*` 命名空间下。`default.nix` 是聚合入口，负责导入子模块、设置 Home Manager 基线，以及计算共享的代理地址。

- 各功能模块通常在 `fool/<name>/default.nix` 中声明 option，并用 `mkIf` 按主机启用。
- 主机侧开关集中在 `home/<profile>/default.nix`，不要在聚合入口硬编码某台机器的选择。
- `overlays/` 例外：它由系统模块列表直接导入，用于把外部 flake 包放入 `pkgs`。
- 修改代理逻辑时同时检查 `fool.proxy` 的用户态字段和 `os/default.nix` 的系统态字段。
