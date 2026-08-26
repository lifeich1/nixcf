# 防火墙

`default.nix` 始终开启 NixOS firewall，并提供：

- `fool.firewall.non-strict`：默认允许 TCP/UDP 2048–65535。
- `serve-hobob`：明确开放 TCP 3731。
- `serve-friedegg`：明确开放 TCP 3000（Gitea）。

Pi profile 启用两个服务端口。收紧策略时注意默认 `non-strict = true`，仅添加单端口规则并不会关闭宽端口范围。
