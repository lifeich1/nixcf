# nixcf Agent Instructions

本仓库是三台机器共用的 NixOS flake。本文只记录 agent 必须遵循的规则；项目结构和模块职责请按需读取各目录的 `readme.md`。

## 阅读策略

1. 先读根目录 `README.md` 和 `flake.nix`，确定目标 host、Home Manager profile 与模块入口。
2. 再读目标目录及其父目录的 `readme.md`。
3. 只打开任务涉及的 `host/`、`home/`、`os/` 或 `fool/` 源码，不要为了了解单个模块扫描整个仓库。
4. 配置版本、input 和当前启用状态以源码及 `flake.lock` 为准，不要把 README 中的描述当作固定事实。

## 配置边界

- `flake.nix`：组装 `nixosConfigurations`，传递 `username`、`device`、`home-nix` 等主机参数。
- `host/<hostname>/`：硬件、启动、用户以及该主机的系统服务开关。
- `home/<profile>/`：该主机启用的 Home Manager 功能；不要在这里实现通用模块。
- `os/<module>/`：可复用的 NixOS 系统模块。
- `fool/<module>/`：可复用的 Home Manager 用户模块。
- `fool/overlays/`：从 flake inputs 向 `pkgs` 注入个人包。
- `secrets/`：Agenix 声明、接收者和加密载荷。

主机对应关系：

| NixOS configuration | Home profile | User | Architecture |
|---|---|---|---|
| `nixos-gtr7` | `home/pc` | `fool` | `x86_64-linux` |
| `nixos-xps13` | `home/lightpad` | `fool` | `x86_64-linux` |
| `nixos-pi4b` | `home/micro-srv` | `pi` | `aarch64-linux` |

## 模块约定

用户模块使用 `fool.*` 命名空间。新模块通常应：

1. 在 `fool/<name>/default.nix` 或 `os/<name>/default.nix` 声明 option。
2. 使用 `mkIf`/`mkMerge` 按 option 启用配置。
3. 在父级 `default.nix` 中导入。
4. 在对应 `home/<profile>` 或 `host/<hostname>` 中选择启用。
5. 同步更新新目录或受影响目录的 `readme.md`。

共享逻辑应下沉到模块；不要复制到多个 host/profile。修改代理时同时检查用户态和系统态的 `fool.proxy` 定义。

## 安全与兼容性

- 不要解密、输出或复制 `.age` 明文、服务 token、私钥或密码到文档、日志和提交信息。
- 修改 secret 时使用 Agenix，并同步检查 `secrets/secrets.nix` 的接收者。
- `hardware-configuration.nix` 是硬件扫描结果，除非任务明确涉及硬件变化，否则不要改。
- 不要随意修改 `system.stateVersion` 或 `home.stateVersion`；升级 input 不等于升级 state version。
- `host/common.nix` 中的 substituters、public keys、netrc 与 Pi 上 Attic 服务相互依赖，修改时必须一起核对。
- Pi 是 `aarch64-linux`；涉及外部包或 overlay 时确认目标架构存在对应 output。

## 验证与提交

- 文档改动：至少运行 `git diff --check` 并检查路径/描述与源码一致。
- Nix 配置改动：优先运行 `just chk`；若无法完成，明确报告未验证项和原因。
- 部署命令为 `just pi`、`just xps`、`just gtr7`，会连接远端并创建部署 tag；除非用户明确要求，不要执行部署。
- 不要提交、打 tag 或更新 flake inputs，除非用户明确要求。
- 需要提交信息时遵循 `.agents/skills/commit-message/SKILL.md`：`<emoji> <component>: <short description>`。
