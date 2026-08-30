# 项目维护约定

本目录保存供开发者和 agent 查阅的项目本地规范，不参与 NixOS 构建。

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
