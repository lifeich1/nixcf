# Competitive Programming Guard

`default.nix` 从 `inputs.cp-guard` 取当前架构的包，并以用户级 systemd 服务运行。

- `fool.cp-guard.enable` 控制服务。
- `fool.cp-guard.dir` 指定竞赛源码目录，默认位于用户 home 下。
- 外部包来源在根目录 `flake.nix`；当前由 `home/pc` 启用。
