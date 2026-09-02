# `host/`：主机配置

每个 `nixos-<device>/` 保存硬件、启动、用户和服务开关；host 元数据（用户名、Home
profile、硬件模块、deploy target）以根目录 `hosts.nix` 为唯一来源。

共享的 NixOS 设置按职责下沉到 `os/`：基础系统在 `os/base/`、访问策略在 `os/access/`、
Nix/cache 在 `os/nix/`。主机目录只负责机器差异；通用可复用逻辑不放在 `host/`。
