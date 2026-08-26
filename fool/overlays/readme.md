# Nixpkgs overlays

`default.nix` 是系统级 overlay 聚合入口，目前只导入 `hobob/`。

本目录由根 `flake.nix` 的基础模块列表加载，不是普通 Home Manager 子模块。新增个人包 overlay 时在此导入，并确认所有目标架构都有对应输出。
