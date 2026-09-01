# Attic 客户端

`default.nix` 通过 `fool.attic.watch-store` 控制用户级 `attic-watch-store` 服务，监听 Nix Store 并上传到 `my-pi_attic`。

- `$XDG_CONFIG_HOME/attic/config.toml` 通过 Home Manager `mkOutOfStoreSymlink` 指向 Agenix 运行时文件 `/run/agenix/attic-client-config`（仅 GTR7 host key 加密、`fool` 可读），不再把 token 复制进 store。
- 当前仅 `home/pc` 启用。
- 服务依赖 Pi 上的 `os/atticd` 和 `host/common.nix` 中的 cache 配置。
