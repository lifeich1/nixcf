# `os/`：NixOS 系统模块

`default.nix` 只做模块聚合，不含 option 或 config。

- `base/`、`access/` 与 `nix/`：系统基础（locale、时区、基础包、SSH daemon）、访问策略
  （root authorized keys）与 Nix/cache 配置。
- `homelab/`：Pi 端点、SOCKS/migration proxy 端口与 Attic endpoint/cache/public key 的
  类型化唯一来源。
- `collections/` 与 `plasma/`：桌面主机软件、音频和图形环境。
- `firewall/`、`sudo/`、`proxychains/`：系统策略。
- `atticd/`、`gitea/`、`hobob/`、`syncthing/`、`virtualbox/`、`vlmcsd/`：可选服务。

新模块应声明 `fool.<name>` option、在此导入，并由 `host/<name>/configuration.nix` 选择启用。
