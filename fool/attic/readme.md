# Attic 客户端

`default.nix` 通过 `fool.attic.watch-store` 控制用户级 `attic-watch-store` 服务，监听 Nix Store 并上传到 `my-pi_attic`。

- `attic-client.toml` 被部署到 `$XDG_CONFIG_HOME/attic/config.toml`。
- 当前仅 `home/pc` 启用。
- 服务依赖 Pi 上的 `os/atticd` 和 `host/common.nix` 中的 cache 配置。
