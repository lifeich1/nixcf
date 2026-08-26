# Attic daemon

`default.nix` 提供 `fool.atticd.enable`，监听 8080 端口，配置分块去重和六个月默认保留期，并把环境文件部署到 `/etc/fool/attic/atticd.env`。

- 本模块由 Pi4B 在根 `flake.nix` 中显式导入并启用。
- `atticd.env` 可能包含服务配置，不要把其内容复制到文档或日志。
- 客户端与 substituter 分别在 `fool/attic`、`host/common.nix`。
