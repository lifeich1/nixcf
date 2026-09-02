# `os/base/`：系统基础

拥有 locale、时区、基础 package、EDITOR、Zsh 与 OpenSSH daemon，以及
`boot.loader.systemd-boot.configurationLimit` 默认值。

该目录承接原 `os/default.nix` 与 `host/common.nix` 中的基础系统设置，由
`os/default.nix` 聚合导入，所有 host 共用。
