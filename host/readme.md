# `host/`：主机配置

`common.nix` 保存所有机器共享的 NixOS 设置；每个 `nixos-<device>/` 保存硬件、启动、用户和服务开关。

根 `flake.nix` 会把 `common.nix` 与目标主机的 `configuration.nix` 一起加入模块列表。主机目录应只负责机器差异，通用可复用逻辑应下沉到 `os/` 或 `fool/`。

注意：`common.nix` 含 homelab cache 的访问配置。文档中不要复制令牌；修改 cache 时检查 substituters、public keys、netrc 和 Attic 服务是否一致。
