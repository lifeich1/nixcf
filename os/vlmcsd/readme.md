# vlmcsd

`default.nix` 通过 `fool.vlmcsd.enable` 以 NixOS OCI container（backend=podman）运行 KMS
服务（`docker.io/mikolatero/vlmcsd:latest`，映射 `1688:1688`）。TCP 1688 入站规则由本
module 拥有，host 需显式设置 `fool.vlmcsd.openFirewall = true`（Pi 已开启）。

`cmd` 分支与 `invokeType` option 已删除（refactor-plan-04 阶段 8）：Pi 只用 OCI 声明。
镜像仍为 `latest`；固定 digest 需先在 Pi/aarch64 pull 验证 manifest 后单独切换
（提交 8，部署序列）。
