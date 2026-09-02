# Proxychains

`default.nix` 始终启用 `programs.proxychains`，定义名为 `lray` 的 SOCKS5 代理。

host/port 从 `os/homelab` 派生：`fool.homelab.proxy.use-pi` 为 true 时指向 Pi 的
LAN address，否则指向 `127.0.0.1`；端口为 `fool.homelab.proxy.socksPort`。
