# 重构计划 02：无行为清理

本计划对应 `refactor-audit.md` 建议顺序的第 2 步：删除已确认的死 input、死参数、重复配置
和无消费者模块，同时保持三台主机的求值结果与用户可见行为不变。计划 01 完成后再执行，
避免在安全迁移期间扩大 diff。

## 目标

- `flake.nix` 只传递实际使用的 input、参数和 package。
- 删除没有消费者且不应继续维护的模块或分支。
- 基础 package 只有一个所有者。
- cp-guard 与主 flake 共享 nixpkgs，避免重复锁定 package set。
- 重构前后的 host、用户、服务、package 和 Home Manager 开关基线一致。

## 决策默认值

实施前在 issue 或计划执行记录中确认以下默认决策：

| 项目 | 推荐结果 | 说明 |
|---|---|---|
| `fool.xray.installer` | 删除 | 与 NixOS declarative Xray 冲突 |
| 用户态 `fool.hobob` | 删除 | 无启用者，系统服务另行重构 |
| `fool.kitty` | 删除 | 无启用者，需要时按当前 API 重建 |
| VirtualBox guest 分支 | 删除 | 无启用 host |
| cp-guard nixpkgs | follows 主 `nixpkgs` | 若上游不兼容，停止并记录隔离原因 |

`minpac` 和 Avante 虽然存在疑似死配置，但属于 Nvim 行为面，留到计划 05。旧 mirror 注释不
影响求值，可随对应 input 行删除，不单独扩大清理范围。

## 范围

- `flake.nix` 和必要的 `flake.lock` 变更。
- `os/default.nix`、`os/collections/default.nix` 的重复基础 package。
- `fool/default.nix` 的 import 列表。
- 被确认删除的 `fool/xray`、`fool/hobob`、`fool/kitty` 和 VirtualBox guest 分支。
- 对应 README、父级目录索引和 host/profile 描述。

不在本计划中改 option 命名、端点、firewall、服务用户、Home baseline 或部署 recipe。

## 基线快照

在 `/tmp` 或被忽略的 `.plans/` 中保存可机器比较的 JSON，不提交生成物。每台 host 至少记录：

- `pkgs.stdenv.hostPlatform.system`、hostname、普通用户和 Home Manager user。
- bootloader、kernel package 名称和 `system.stateVersion`。
- `environment.systemPackages` 与 `home.packages` 的 package name 集合。
- 所有当前启用的 `fool.*`、关键 NixOS service 和 Home Manager program。
- firewall 端口范围、Agenix secret metadata、substituter 和 trusted key。

使用排序后的 JSON 做 diff，避免 Nix attrset 顺序造成噪声。涉及 derivation 时比较 package
name 或 drvPath；不要把 secret 内容纳入快照。

## 实施阶段

### 1. 删除 stable input 和死 specialArgs

- 删除 `nixpkgs-stable` input、outputs 形参和 `pkgs-stable` import。
- 删除 XPS13 的 `pkgs-stable`、`all_proxy`、未使用的 `lib` 等形参。
- 删除 host registry 的 `hasPi`、传入模块的 `has_pi` 和固定 `all_proxy`。
- 删除 `_module.args.nixos-hardware`；保留 input 及 registry 中实际使用的 hardware module。
- 将 Home Manager 对 `system` 的读取改为 `pkgs.stdenv.hostPlatform.system`，确认无消费者后
  不再传递 `system`。

每删除一类参数后运行 `rg` 和三 host eval，避免把动态 attr 名引用误判为死代码。

### 2. 缩小 NixOS 与 Home Manager 参数边界

把 `mkHost` 中共享的 `args` 拆成明确的 system specialArgs 和 Home Manager
`extraSpecialArgs`。本阶段只减少参数，不引入新的 registry 或 endpoint 抽象；后者属于
计划 03。

允许 Home Manager 接收的内容仅限当前模块真实使用的 `username`、必要 package/input 和
其他已证明依赖。完整 `inputs` 若仍被 Nvim、cp-guard 等使用，应先保留，待对应 package
option 落地后再删除。

### 3. 统一基础 package 所有权

`vim`、`wget`、`git` 只在一个基础集合中声明。推荐保留在后续将迁移为 `os/base` 的基础
配置中，`os/collections/default.nix` 只保留 collection 特有 package，例如 `dmidecode`。

比较三台主机的最终 `environment.systemPackages`，确认只消除重复项，没有从 Pi 或桌面
closure 删除基础工具。

### 4. 删除无消费者模块和分支

- 从 `fool/default.nix` 移除 Xray installer、用户态 Hobob 和 Kitty import，并删除目录。
- 从 `os/virtualbox/default.nix` 删除 guest option 和 guest config 分支，保留 GTR7 host 模式。
- 删除相关 README 条目和已经失效的跨模块说明。
- 使用 `rg` 检查 option、目录名、生成命令和旧 README 引用均无残留。

一个模块一条删除提交。若实施时发现未跟踪的本地消费者或近期使用要求，保留该模块并将
决策写回审计，不用占位开关伪装为已清理。

### 5. 让 cp-guard follows 主 nixpkgs

为 `cp-guard` input 增加 `inputs.nixpkgs.follows = "nixpkgs"`，只更新该 input 相关 lock node。
先在 `x86_64-linux` 的 GTR7 Home profile 求值并构建 cp-guard package；若上游 package API
与当前 nixpkgs 不兼容，回退 follows 变更并记录必须隔离的具体错误。

该步骤会修改 `flake.lock`，实施前需要用户明确授权 input/lock 更新。不能借机升级其他
input，也不能接受无关 lock churn。

### 6. 清理参数和注释残留

运行 `deadnix` 作为发现工具，逐条人工确认后删除未使用形参、`with` 或 let binding。此时
不把 `deadnix` 正式接入 flake check，也不进行全仓库格式化；静态检查接入属于计划 05。

只修正本批改动触及的 README。文档必须描述当前入口和开关，不保留“已经删除但可能回来”
的模块目录占位。

## 建议提交拆分

1. `:coffin: flake: remove unused arguments`
2. `:recycle: os: dedupe base packages`
3. `:coffin: xray: remove imperative installer`
4. `:coffin: hm: remove unused modules`
5. `:coffin: virtualbox: remove guest mode`
6. `:recycle: cp-guard: follow main nixpkgs`

cp-guard 的 `flake.nix` 和最小 `flake.lock` 变更必须在同一提交。其余提交不应修改 lock。

## 验证

- 每个提交运行 `just chk`；整批结束运行 `git diff --check`。
- 对比重构前后的三 host JSON 基线，允许差异仅限已删除 option 和重复 package 表达。
- 定向构建 GTR7 的 cp-guard package 和三台主机的 Home Manager activation package。
- `rg` 确认 `nixpkgs-stable`、`pkgs-stable`、`hasPi`、`has_pi`、`all_proxy` 和已删除 option
  没有引用。
- 使用 `nix flake metadata --json` 检查 cp-guard 不再引入独立 nixpkgs node。
- 检查 `flake.lock` diff，拒绝其他 input revision 变化。

## 回滚

- 参数删除可逐提交回退，不改变持久状态。
- 删除模块的回滚只恢复模块代码和 import，不得顺带恢复计划 01 已删除的明文凭据。
- cp-guard follows 失败时整体回退对应 `flake.nix`/`flake.lock` 提交，保留上游不兼容记录。

## 完成标准

- 所列死参数和无消费者模块均已删除或有明确保留理由。
- 三台 host 的关键求值与基线一致。
- cp-guard 共享主 nixpkgs，或已记录可复现的不兼容证据。
- 全部提交可独立解释和回退，没有混入端点、服务策略或版本升级。
