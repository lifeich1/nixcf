# Gitea

`default.nix` 通过 `fool.gitea.enable` 启用 Gitea 与 LFS。

options：

- `fool.gitea.domain`：`server.DOMAIN`，默认 `fool.homelab.pi.hostName`（my-pi）。
- `fool.gitea.migrationProxy`：GitHub migration 经本机 HTTP migration proxy
  （127.0.0.1:`fool.homelab.proxy.migrationPort`）。
- `fool.gitea.allowRegistration`：允许公开注册，默认 `false`（账户已在 Pi 创建）。
- `fool.gitea.openFirewall`：开放 3000/tcp 入站，规则由本 module 拥有。

当前由 Pi 启用（并显式开启 `openFirewall` 与 `migrationProxy`）。3000/tcp 的入站规则
不再经 `os/firewall`。`mailer.SENDMAIL_PATH` 占位已删除：上游 `services.gitea` module
自行声明并按 `mailer.ENABLED/PROTOCOL` 派生（refactor-plan-04 阶段 5 求值确认，mailer
未启用）。数据库、repository、LFS 路径与现有用户保持不变。
