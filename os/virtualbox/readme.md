# VirtualBox

`default.nix` 提供两个独立开关：

- `fool.virtualbox.enable`：启用 host、Extension Pack 与 KVM backend。
- `fool.virtualbox.guest-enable`：启用 guest additions。

GTR7 使用 host 模式。启用 host 时用户还需在对应 host 配置中加入 `vboxusers` 组。
