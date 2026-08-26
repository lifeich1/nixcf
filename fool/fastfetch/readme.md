# Fastfetch 配置部署

`default.nix` 提供可空的 `fool.fastfetch.configFile`。传入路径后，将其部署为 `$XDG_CONFIG_HOME/fastfetch/config.jsonc`。

模块不负责安装主程序；Zsh 模块会安装 Fastfetch。Pi profile 使用 `home/micro-srv/fastfetch-config.jsonc`。
