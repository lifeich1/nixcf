# `os/homelab/`：homelab 端点与 Pi 解析/代理语义

类型化配置的唯一来源：

- `pi.hostName` / `pi.lanAddress` / `pi.resolvable`：Pi 的 DNS name、LAN address 与
  “是否把该解析写入 `networking.hosts`”。
- `proxy.socksPort` / `proxy.migrationPort`：SOCKS5 端口与 Gitea migration HTTP 端口
  （两者必须保持独立）。
- `attic.scheme` / `attic.port` / `attic.cacheName` / `attic.publicKey`：Attic 端点
  与签名 public key（非 secret；token 只在 `/run/agenix` 运行时提供）。

`pi.resolvable` 控制共享 `networking.hosts` 条目；Pi 本机解析到 loopback 的策略由
`host/nixos-pi4b/configuration.nix` 的 `networking.extraHosts` 显式维护，不重复注入
LAN 地址。

消费者：`os/nix`（substituter/key）、`os/proxychains`（SOCKS host/port）、`os/gitea`
（DOMAIN、migration proxy）、`os/atticd`（listen port）、Home Manager（经 `osConfig`
只读，见 `fool/`）。
