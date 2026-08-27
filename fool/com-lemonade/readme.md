# Lemonade 反向通道

`default.nix` 提供 `fool.com-lemonade.enable`，生成 `com-lemonade` 命令：启动本地 Lemonade server，并通过 SSH 建立 2489 端口反向转发。

桌面 profile 当前会显式启用它。默认 SSH 目标为 `com`，也可把目标作为第一个参数传入。
