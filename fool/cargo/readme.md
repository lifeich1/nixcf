# Cargo

`default.nix` 通过 `fool.cargo.ctrl-config` 决定是否把 `config.toml` 部署为 `~/.cargo/config.toml`。

`config.toml` 保存 Cargo registry/mirror 设置；修改镜像只需改该文件。桌面和轻薄本 profile 均启用此模块。
