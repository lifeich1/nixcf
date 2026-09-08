# SSH 客户端

`default.nix` 始终启用 Home Manager SSH 基线（GitHub 连接经 `fool.proxy.tcp_url`
生成 SOCKS5 `ProxyCommand`），个人主机别名由 `fool.cfg-ssh.hosts` option 提供，
真实 host/user 数据放在 profile 层（`home/desktop-common.nix`、`home/micro-srv`），
不在模块内写死 endpoint。

- 公共默认值（`*` 与 `github.com`）在本文件中，与个人别名合并渲染为 `~/.ssh/config`。
- 新增主机：在对应 profile 的 `fool.cfg-ssh.hosts` 增加条目即可，无需改模块。
- 此处是客户端配置；系统 SSH 服务由 `os/default.nix` 管理。
