# Sudo

`default.nix` 为 flake 传入的 `username` 创建 sudo rule。`fool.sudo.nopass` 会把规则切换为 `NOPASSWD`，内部 option `extra-options` 用于合并最终参数。

桌面主机目前启用免密 sudo；Pi 未显式启用。新增精细授权时优先增加独立 rule，不要扩大现有 `ALL` 规则语义。
