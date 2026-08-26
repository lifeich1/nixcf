# Gitea

`default.nix` 通过 `fool.gitea.enable` 启用 Gitea 与 LFS，域名为 `my-pi`，关闭公开注册，并为 GitHub migration 配置本地代理。

当前由 Pi 启用，对外端口由 `os/firewall` 管理。修改域名、代理或注册策略时同时检查主机名解析和 firewall。
