# vlmcsd

`default.nix` 通过 `fool.vlmcsd.enable` 以 NixOS OCI container（backend=podman）运行 KMS
服务。TCP 1688 入站规则由本 module 拥有，host 需显式设置 `fool.vlmcsd.openFirewall =
true`（Pi 已开启）。

options：

- `fool.vlmcsd.image`：container image，默认固定到 2026-09-08 registry 验证的 OCI index
  digest（`sha256:aadb2a38…5d0c`，含 linux/arm64 与 amd64 manifest）；不随 `latest`
  漂移。
- `fool.vlmcsd.port`：host/container 端口（默认 1688），映射字符串由 module 生成。

`cmd` 分支与 `invokeType` option 已删除（refactor-plan-04 阶段 8）。digest 切换前已在
Pi/aarch64 pull 验证（若验证失败，用 host override 的 `image` 回退 `:latest`）。
