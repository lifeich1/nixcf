# `os/access/`：系统访问策略

提供 root authorized keys；管理员 public key 集合来自 flake.nix 的 `adminKeys`，
Pi 的 `pi` 用户 access 在 `host/nixos-pi4b/configuration.nix` 显式选择同一来源。
