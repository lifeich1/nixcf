# 项目维护约定

本目录保存供开发者和 agent 查阅的项目本地规范，不参与 NixOS 构建。

## Codex skills

以下目录是以 `SKILL.md` 为入口的仓库专用 workflow：

| Skill | 用途 |
|---|---|
| `nixcf-module-change/` | 路由、实现和验证 NixOS/Home Manager 模块变更 |
| `nixcf-secrets-agenix/` | 安全审查和修改 Agenix 声明、接收者与运行时接线 |
| `nixcf-service-firewall/` | 整理服务边界、端口所有权、firewall、状态和回滚 |
| `nixcf-flake-package/` | 修改 flake input、lock、overlay 和外部 package 消费链 |
| `nixcf-nixvim/` | 维护 Nixvim、插件、LSP、keymap、provider 和多主机验证 |
| `nixcf-deploy/` | 分阶段检查、部署、验证、打 tag 和 generation 回滚 |

每个 skill 的 `agents/openai.yaml` 提供 UI 元数据；详细资料仅按 `SKILL.md` 的路由读取。
部署、input/lock 更新、凭据操作、提交和 tag 仍分别需要用户明确授权。
任何会消费本仓库 flake 的 Nix eval、build、check、lock、activation 或 deployment，必须先通过
`nixcf-secrets-agenix/scripts/check-nix-source-safety.sh`；门禁失败时不得读取其报告的源文件，也不得运行 Nix 命令。

`commit-message.md` 记录从历史提交归纳的 Gitmoji 格式：`<emoji> <component>: <short description>`。准备提交信息时先读取该文件，保持与仓库历史一致。

`refactor-audit.md` 记录 2026-08-30 的全仓库重构审查，按安全、结构、服务、Home Manager
与运维分级，并给出实施批次、验收方式和待决策项。实施其中事项前先核对当前源码，避免把
审查时点的描述当作长期事实。

审查建议的前五步分别展开为以下实施计划：

- `refactor-plan-01-credentials.md`：凭据轮换、Agenix identity 和 runtime secret。
- `refactor-plan-02-cleanup.md`：死 input/参数/模块与重复配置的无行为清理。
- `refactor-plan-03-host-endpoints.md`：主机 registry、homelab endpoint 和外部 package 注入。
- `refactor-plan-04-firewall-services.md`：默认拒绝的 firewall 与系统服务所有权。
- `refactor-plan-05-home-operations.md`：Home Manager、Nvim、运维脚本和静态检查。

五份计划按编号顺序实施。每份计划中的真实部署、凭据轮换、input 更新和 tag 操作仍需单独
获得授权；完成本地代码和求值不能替代真实主机验收。
