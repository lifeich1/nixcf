# Sudo

`default.nix` 为 flake 传入的 `username` 创建 sudo rule。`fool.sudo.nopass` 启用时直接在
rule 里加上 `NOPASSWD`；不再暴露内部拼接用的 `extra-options` option（audit §16）。

桌面主机目前启用免密 sudo；Pi 未显式启用。新增精细授权时优先增加独立 rule，不要扩大现有 `ALL` 规则语义。
