# Proxychains

`default.nix` 始终启用 `programs.proxychains`，定义名为 `lray` 的 SOCKS5 代理，默认指向 `127.0.0.1:10809`。

当 `fool.proxy.has-pi && fool.proxy.use-pi` 时，代理主机切换为 Pi 的局域网地址。代理 option 的系统级定义在 `os/default.nix`。
