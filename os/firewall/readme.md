# 防火墙

`default.nix` 始终开启 NixOS firewall，默认拒绝未声明的入站连接（refactor-plan-04 阶段 3
完成后已删除 `fool.firewall.non-strict` 与宽端口范围）。

服务端口规则由各服务 module 或 host 单一拥有（host 通过对应的 `openFirewall` option
显式开启，或直接声明无系统 module 的 host 特有端口）：

| 端口 | 规则所有者 | host 开关 |
|---|---|---|
| 3731/tcp (hobob) | `os/hobob` | `fool.hobob.openFirewall` |
| 3000/tcp (gitea) | `os/gitea` | `fool.gitea.openFirewall` |
| 8080/tcp (atticd) | `os/atticd` | `fool.atticd.openFirewall` |
| 1688/tcp (vlmcsd) | `os/vlmcsd` | `fool.vlmcsd.openFirewall` |
| 22000/tcp、21027/udp (syncthing) | 上游 `services.syncthing` | `fool.syncthing.openFirewall` |
| 1714-1764/tcp+udp (KDE Connect) | 上游 `programs.kdeconnect`（enable 自动开放） | 随 `fool.plasma.enable` 启用 |
| 9090/tcp (calibre wireless/content server) | gtr7 host（calibre 为用户层 GUI 服务，无系统 module） | 仅 GTR7；xps13 不开放 |
| 9119/tcp (Hermes Agent dashboard backend) | gtr7 host（容器由仓库外 podman-compose 常驻，无系统 module） | 仅 GTR7；xps13 不开放 |
| 10809/tcp (xray SOCKS) | Pi host（xray 无系统 service module；gtr7 `use-pi` 出网依赖） | 仅 Pi 对 gtr7 开放；UDP 不开 |
| 22/tcp (OpenSSH) | NixOS OpenSSH module | 不在此处 |

新增网络服务时：优先让服务 module / 上游 module 拥有 typed `port`/`openFirewall`，
host 只在无系统 module 时才直接声明端口（单一所有者），禁止退回 `serve-<app>` 式开关
或宽 range。
