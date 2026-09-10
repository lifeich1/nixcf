# Agenix secrets

本目录只保存 Agenix 声明、接收者映射和加密后的 `.age` 文件。

- `default.nix`：声明 Xray 配置、按主机选择的用户密码，以及 Attic 运行时 secret（服务端环境、netrc、watch-store 客户端配置），并设置解密后的目标路径、owner 与 mode。
- `fool.secrets.pass`：typed enum（`gtr-pass` / `pi-pass` / `xps-pass`），只能选择仓库中已存在的密码密文，并带“文件必须存在”的 assertion；新增主机时同步此枚举与 `secrets.nix` 接收者。
- `secrets.nix`：维护各 `.age` 文件可用的 SSH public keys；系统 secret 只授权各主机 `/etc/ssh/ssh_host_ed25519_key.pub`。
- `*.age`：加密载荷；不要尝试把明文写入 README、提交信息或 agent 输出。

## 运行时 secret 一览

| secret | 目标路径 | owner | 消费者 |
|---|---|---|---|
| `xray-config.json.age` | `/usr/local/etc/xray/config.json` | root:root `0400` | `services.xray`（`LoadCredential`） |
| `atticd-env.age` | `/run/agenix/atticd-env` | root:root `0400` | Pi `services.atticd.environmentFile` |
| `attic-netrc-<device>.age` | `/run/agenix/attic-netrc` | root:root `0400` | `nix.settings.netrc-file`（pull） |
| `attic-client-config.age` | `/run/agenix/attic-client-config` | fool:root `0400` | GTR7 `attic-watch-store`（push） |

新增 secret 时需同时更新 `secrets.nix` 的接收者和 `default.nix`/使用模块。编辑使用 `agenix -e secrets/<name>.age`，不要用普通文本工具覆盖密文。轮换 Attic 凭据时在 Pi 上用 `atticadm make-token` 签发，再以 Agenix 覆盖对应密文。
