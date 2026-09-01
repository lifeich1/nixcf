# Attic daemon

`default.nix` 提供 `fool.atticd.enable`，监听 8080 端口，配置分块去重和六个月默认保留期；环境文件通过 Agenix 在运行时解密到 `/run/agenix/atticd-env`（`services.atticd.environmentFile`）。

- 本模块由 Pi4B 在根 `flake.nix` 中显式导入并启用。
- 签名 secret 与网络代理变量由 `secrets/atticd-env.age` 管理（仅 Pi host key 可解密）；不要把内容复制到文档或日志。
- 客户端与 substituter 分别在 `fool/attic`、`host/common.nix`。
