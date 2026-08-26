# Zsh

`default.nix` 通过 `fool.zsh.enable` 配置 Oh My Zsh、Powerlevel10k、常用 CLI 和用户配置文件。

- `zshrc`、`zshenv`、`p10k.zsh` 被部署到 `~/.lintd/zsh/`。
- `instant-prompt.nix` 注入 Fastfetch 和 Powerlevel10k instant prompt。
- `skim.nix` 提供 `fool.zsh.with-skim`。
- 根目录 `just zsh` 用于快速同步开发配置，执行前留意 `.bak` 文件。
