# Atticd

`default.nix` 提供：

- `fool.atticd.enable`：启用 atticd 服务。
- `fool.atticd.port`：服务端口，默认 `fool.homelab.attic.port`（8080）。
- `fool.atticd.listenAddress`：listen 地址，默认 `[::]`。
- `fool.atticd.package`：atticd package，默认 `pkgs.attic-server`。
- `fool.atticd.retention`：`garbage-collection.default-retention-period`，默认 `6 months`。
- `fool.atticd.openFirewall`：开放 8080/tcp 入站（gtr7/xps13 substituter 经 LAN 访问），
  收紧宽范围前须由 host 显式开启。

chunking 参数（nar-size-threshold 64KiB、min 16KiB、avg 64KiB、max 256KiB）与现有数据
格式绑定，保持原值、不做 option。环境文件通过 Agenix 在运行时解密到
`/run/agenix/atticd-env`（`services.atticd.environmentFile`）。
