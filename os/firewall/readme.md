# 防火墙

`default.nix` 始终开启 NixOS firewall，并提供：

- `fool.firewall.non-strict`：默认允许 TCP/UDP 2048–65535（重构计划阶段 3 前保持开启）。

服务端口规则不在此处维护，由各服务 module 或上游 module 单一拥有（host 通过对应的
`openFirewall` option 显式开启）：

| 端口 | 规则所有者 | host 开关 |
|---|---|---|
| 3731/tcp (hobob) | `os/hobob` | `fool.hobob.openFirewall` |
| 3000/tcp (gitea) | `os/gitea` | `fool.gitea.openFirewall` |
| 8080/tcp (atticd) | `os/atticd` | `fool.atticd.openFirewall` |
| 1688/tcp (vlmcsd) | `os/vlmcsd` | `fool.vlmcsd.openFirewall` |
| 22000/tcp、21027/udp (syncthing) | 上游 `services.syncthing` | `fool.syncthing.openFirewall` |
| 1714-1764/tcp+udp (KDE Connect) | 上游 `programs.kdeconnect`（enable 自动开放） | 随 `fool.plasma.enable` 启用 |
| 9090/tcp (calibre wireless/content server) | gtr7 host（calibre 为用户层 GUI 服务，无系统 module） | 仅 GTR7；xps13 不开放 |
| 22/tcp (OpenSSH) | NixOS OpenSSH module | 不在此处 |

收紧策略时注意默认 `non-strict = true`，仅添加单端口规则并不会关闭宽端口范围；
关闭宽范围（阶段 3）前需逐台确认上表端口均已按需开放。
