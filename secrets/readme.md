# Agenix secrets

本目录只保存 Agenix 声明、接收者映射和加密后的 `.age` 文件。

- `default.nix`：声明 Xray 配置和按主机选择的用户密码 secret，并设置解密后的目标路径。
- `secrets.nix`：维护各 `.age` 文件可用的 SSH public keys。
- `*.age`：加密载荷；不要尝试把明文写入 README、提交信息或 agent 输出。

新增 secret 时需同时更新 `secrets.nix` 的接收者和 `default.nix`/使用模块。编辑使用 `agenix -e secrets/<name>.age`，不要用普通文本工具覆盖密文。
