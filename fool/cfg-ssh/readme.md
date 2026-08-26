# SSH 客户端

`default.nix` 始终启用 Home Manager SSH 配置，并提供 `vultr`、`qcraft`、`soc` 三组可选主机别名。

- GitHub 连接使用 `fool.proxy.tcp_url` 生成 SOCKS5 `ProxyCommand`。
- 公共默认值和分组主机都在本文件中；新增环境应优先增加独立 option。
- 此处是客户端配置；系统 SSH 服务由 `os/default.nix` 管理。
