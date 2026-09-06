# VirtualBox

`default.nix` 提供 `fool.virtualbox.enable`，启用 host、Extension Pack 与 KVM backend；
`fool.virtualbox.users` 列出加入 `vboxusers` 组的用户（module 统一派生，host 不再手写
extraGroups，refactor-plan-04 阶段 9）。GTR7 使用：`enable = true; users = [ "fool" ];`。
