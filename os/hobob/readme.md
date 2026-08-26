# Hobob 系统服务

`default.nix` 通过 `fool.hobob.sys-service` 创建系统级 `programs-hobob` service，以 `/opt/hobob` 为工作目录运行 `pkgs.hobob`。

Pi 同时启用 `fool.hobob.overlay` 来提供该包。用户态包模块位于 `fool/hobob`，不要混淆两个相同命名空间下的不同开关。
