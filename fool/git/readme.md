# Git

`default.nix` 配置 Git、LFS、Difftastic 和用户身份，option 为 `user`、`email`、`github-proxy`。

开启 `github-proxy` 后，仅对约定的 GitHub 工作树路径注入 `fool.proxy.socks5_url`，不会全局代理所有仓库。提交风格见 `skill/commit-message.md`。
