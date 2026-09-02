# Competitive Programming Guard

`default.nix` 以用户级 systemd 服务运行 cp-guard。

- `fool.cp-guard.enable` 控制服务。
- `fool.cp-guard.package` 由启用点（`home/pc`）显式传入
  `inputs.cp-guard.packages.${pkgs.stdenv.hostPlatform.system}.default`，模块本身不接收
  完整 `inputs`。
- `fool.cp-guard.dir` 指定竞赛源码目录，默认位于用户 home 下。
