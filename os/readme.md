# `os/`：NixOS 系统模块

`default.nix` 是系统模块聚合入口，设置 hostname、locale、SSH、基础包和系统级 `fool.proxy` 选项，并导入各服务子模块。

- `collections/` 与 `plasma/`：桌面主机软件、音频和图形环境。
- `firewall/`、`sudo/`、`proxychains/`：系统策略。
- `gitea/`、`hobob/`、`syncthing/`、`virtualbox/`、`vlmcsd/`：可选服务。
- `atticd/` 只在 Pi 的 flake 模块列表中显式导入，不在本目录聚合入口中。

新模块应声明 `fool.<name>` option、在此导入，并由 `host/<name>/configuration.nix` 选择启用。
