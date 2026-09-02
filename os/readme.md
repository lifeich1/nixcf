# `os/`：NixOS 系统模块

`default.nix` 是系统模块聚合入口，导入各服务子模块，并暂时保留系统级
`fool.proxy` option 与 Pi hosts 解析（将由 `os/homelab/` 接管）。

- `base/`、`access/` 与 `nix/`：系统基础（locale、时区、基础包、SSH daemon）、访问策略
  （root authorized keys）与 Nix/cache 配置。
- `collections/` 与 `plasma/`：桌面主机软件、音频和图形环境。
- `firewall/`、`sudo/`、`proxychains/`：系统策略。
- `atticd/`、`gitea/`、`hobob/`、`syncthing/`、`virtualbox/`、`vlmcsd/`：可选服务。

新模块应声明 `fool.<name>` option、在此导入，并由 `host/<name>/configuration.nix` 选择启用。
