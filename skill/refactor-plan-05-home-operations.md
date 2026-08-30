# 重构计划 05：Home Manager、Nvim 与运维护栏

本计划对应 `refactor-audit.md` 建议顺序的第 5 步：明确 Home Manager 基线，消除用户模块
隐藏依赖，整理 Nvim 和运维脚本，最后接入静态检查与部署保护。该批次依赖计划 01 至 04
已稳定，不应在服务迁移期间同时改变编辑器和部署流程。

## 目标

- 三个 Home profile 从入口即可看出启用功能，共享基线不再隐藏在 `fool/default.nix`。
- 可选模块统一使用清晰的 `enable` 和 typed options，没有跨模块偶然提供 package 的依赖。
- 个人 identity、内网 endpoint 和本地路径位于 profile/data 层，不写死在通用模块。
- Nvim 文件按行为拆分，LSP server 与 package 使用同一来源，AI 开关不存在“启用但未配置”。
- deploy recipe 默认拒绝 dirty tree，成功 tag 能代表实际部署 commit。
- 维护命令不直接修改生成的 `/etc/nix/nix.conf`。
- formatter、Nix lint、shellcheck 和关键 host eval 进入可重复执行的检查入口。

## 决策默认值

| 项目 | 推荐决策 | 原因 |
|---|---|---|
| Home baseline | 新增 `home/common.nix`，三 profile 显式导入 | profile 可读，通用 module 保持可复用 |
| Avante | 暂时移除 `fool.nvim.ai` | 未完成 setup 和 secret/provider 接入 |
| minpac | 删除 input、plugin 和命令 | 当前没有非 Nix plugin |
| Nvim LSP package | 由 Nixvim server option 拥有 | 避免 `clangd`/`ccls` 双清单漂移 |
| dirty deploy | 默认禁止，显式环境变量逃生 | tag 默认可追溯，紧急操作仍可审计 |
| portable proxy script | 删除 | 常规功能已由 `just proxy/no-proxy` 覆盖 |
| 静态工具 | 使用当前 nixpkgs 中的工具 | 不为首轮检查新增 flake input |

如果 Avante 已有明确 provider、secret 来源和使用需求，应另立功能计划完成 setup，而不是在
本批机械拆分中临时接入外部凭据。

## 范围

- `home/common.nix`、`home/desktop-common.nix` 和三个 profile。
- `fool/default.nix` 及 Alacritty、Fastfetch、Zsh、com-lemonade、Git、SSH、misc 等模块。
- `fool/nvim/` 和 `minpac` input/lock node。
- `justfile`、`tools/use-proxy.portable.sh` 和 `tools/readme.md`。
- `flake.nix` 的 formatter/check outputs，以及必要的检查脚本。

不改变 stateVersion、不升级软件版本、不部署主机，也不重新处理计划 04 的服务数据。

## 基线

为三个 Home user 保存以下排序结果：activation package、home package 名称、启用 programs、
user services、XDG files、shell integrations、Nvim wrapper drvPath 和关键 Nvim options。

额外记录：

- GTR7/XPS13/Pi 的 Nvim 启动 smoke test、LSP server executable 列表和现有键位快照。
- `just --list`、三个 deploy dry-run 结果和 tag 命名规则。
- 当前 `just chk` 输出边界，以及 `deadnix`、`statix`、`shellcheck` 的初始问题清单。

lint 初始清单是建立 baseline，不允许一次性自动重写全仓库。

## 实施阶段

### 1. 显式化 Home baseline

新增 `home/common.nix`，由三个 profile 显式导入，承接真正跨主机且始终启用的 Home 设置：
username/homeDirectory/stateVersion、Home Manager 自身、Bash、GPG agent，以及确认需要的 Git、
SSH、Nvim、misc/XDG 基线。

`fool/default.nix` 收缩为模块 imports 和共享 option 定义，不再无条件选择应用。profile 保留
“这台主机启用什么”，`fool/<module>` 只实现“启用后如何配置”。迁移只移动现有值，每一
组移动后比较三个 activation package 的结构化基线。

### 2. 统一 option 形状和模块所有权

- 可选功能统一为 `fool.<name>.enable`；动作型布尔值改为命名清楚的子 option。
- option 采用一致 kebab-case；旧名先用 `mkRenamedOptionModule` 过渡，下一提交再删除兼容层。
- Cargo 等只服务桌面 profile 的薄配置可直接移入 `home/desktop-common.nix`。
- Fastfetch module 同时拥有 package 和 config，优先使用 Home Manager `programs.fastfetch`。
- Zsh 只拥有 shell 配置；`skim`、`eza` 等 package 只有一个 owner。
- `fool.zsh.with-skim` 必须依赖 Zsh enable，或重命名为独立 `fool.skim.enable`。

不要为每个三行配置制造新 module；抽象必须消除真实重复或隐藏依赖。

### 3. 消除跨模块隐藏依赖

- Alacritty 不再隐式启用 Zellij；需要 Zellij 的 profile 显式开启。
- Fastfetch 不再依赖 Zsh 安装 executable。
- `com-lemonade` 的 script 将 `openssh` 加入 `runtimeInputs`，检查后台进程启动并可靠 cleanup。
- cp-guard/Attic user service 使用 `lib.getExe`、明确 restart policy 和 runtime directory。
- 对不合法组合使用 assertion，而不是依赖某个 profile 恰好同时启用另一个模块。

每修复一个依赖，定向构建受影响 profile；不要同时改变应用设置或 package 版本。

### 4. 迁移 identity 与个人环境数据

定义小型 profile data 层，保存 Git name/email、SSH alias/host、竞赛 abbreviation 和个人目录。
通用模块只暴露 typed options，不提供真实个人 endpoint 作为默认值。

Nvim provider 路径从 package option、`config.home.homeDirectory` 或 PATH 派生，不写死
`/home/fool/...`。Pi profile 不能求值桌面用户的绝对路径。涉及 secret 的值继续使用计划
01 的 runtime secret，不进入该 data 文件。

### 5. 机械拆分 Nvim base

先只移动定义，不改变键位、plugin、option 或生成 Lua：

- `editor.nix`：编辑选项、autocmd 和 provider。
- `plugins.nix`：基础 plugin 及其 setup。
- `keymaps.nix`：普通键位和 Workman runtime 接入。
- `workflow.nix`：gitmoji、竞赛缩写、remote clipboard 等个人工作流。

用 `nix eval` 比较 Nixvim config attrset和 wrapper drvPath，运行 `just nvim` smoke test。文件拆分
提交不得同时修 LSP、删除 plugin 或改 Lua。

### 6. 统一 LSP package ownership

建立一份 server 定义，让 Nixvim server option 直接选择 package；删除 `package = null` 与
`home.packages` 第二清单。逐项核对 executable：尤其将配置的 `clangd` 与实际 Clang package
对齐，不再安装不匹配的 `ccls`。

Python LSP 使用当前 package set 的稳定 package 或显式 option，不锁死
`python312Packages`。对 Nix、Rust、Lua、Vim、Bash、Perl、Markdown、JSON/HTML/CSS/ESLint 和
C/C++ 逐项运行启动检查，确认 formatter 和 Treesitter 行为保持不变。

### 7. 删除未完成的 Nvim 管理路径

- 在确认 minpac 没有非 Nix plugin 后，删除命令、plugin 构建、`minpac` input 和对应 lock node。
- 按默认决策删除 Avante plugin、`fool.nvim.ai` option 和 GTR7 profile 开关。
- 若保留 Avante，必须另行定义 provider、runtime secret、setup、依赖和健康检查。

minpac lock 更新只允许删除该 node，不升级其他 input。两项删除分开提交并分别运行 Nvim
smoke test。

### 8. 加固 deploy recipe

将三个 rebuild recipe 收敛为一个内部通用实现，host/target/tag 从计划 03 registry output
读取。wrapper `just pi/xps/gtr7` 保持现有入口。

在构建前执行 clean-tree guard：默认拒绝 staged、unstaged 和 untracked flake source。紧急
逃生使用显式 `ALLOW_DIRTY=1`，输出 dirty revision 并禁止创建正常 deploy tag，或使用带
`-dirty` 的独立审计记录。只有远端 switch 成功且 tree 仍指向同一 commit 时才创建 tag。

为 guard、target 解析、失败不打 tag和 tag 递增写 shell-level test；测试使用临时 Git repo
或 mock command，不连接远端。

### 9. 清理维护脚本

- 删除直接备份/改写 `/etc/nix/nix.conf` 的 `disable-commu` 和 `cfg-rollback`。
- 临时禁用 substituter 使用命令级 `--option`、`NIX_CONFIG` 或 `/run` systemd drop-in，并用
  trap 保证恢复。
- 保留已经使用 `mktemp` 和 `/run/systemd/system` 的 `just proxy/no-proxy` 作为唯一实现。
- 删除 `tools/use-proxy.portable.sh`；若确认有离线分发需求，则改为调用同一受测脚本实现。
- 为所有保留 shell/perl recipe 增加解析检查和 `shellcheck` 可适用检查。

### 10. 接入静态检查和关键 eval

不新增 flake input，使用当前 nixpkgs 提供的 `nixfmt`、`statix`、`deadnix` 和 `shellcheck`：

- 暴露 x86_64-linux 与 aarch64-linux formatter output。
- 增加 formatting check，限定仓库 Nix 文件，不格式化加密或生成文件。
- 为 statix/deadnix 建立明确 baseline；先修本批文件，再逐步收紧到全仓库零告警。
- 为三个 host 增加关键 eval assertion：architecture、username、hostname、Home user、boot、
  firewall、secret mode、service enable 和外部 package availability。
- 脚本检查覆盖 `tools/` 和 justfile 中可提取的 shell script。

`just chk` 继续作为统一入口。Pi 完整 kernel build 成本高，纯求值 check 与完整 toplevel build
分层，不能用跳过 aarch64 求值换取速度。

## 建议提交拆分

1. `:recycle: hm: make common baseline explicit`
2. `:recycle: hm: normalize module options`
3. `:bug: hm: remove hidden dependencies`
4. `:truck: hm: move personal profile data`
5. `:recycle: nvim: split base configuration`
6. `:bug: nvim: align lsp packages`
7. `:coffin: nvim: remove minpac`
8. `:coffin: nvim: remove incomplete ai config`
9. `:rocket: deploy: require traceable worktree`
10. `:hammer: maintenance: stop editing nix.conf`
11. `:white_check_mark: flake: add static checks`

## 验证

- 每个 Nix 提交运行 `just chk`，所有文档/脚本运行 `git diff --check`。
- 比较三个 Home profile 的 package、program、service 和 XDG 基线。
- GTR7、XPS13、Pi 分别构建 Nvim wrapper；桌面逐项启动 LSP，Pi 验证无 LSP package 回归。
- 执行 formatter check、statix、deadnix、shellcheck 和关键 eval assertions。
- 用临时 repo 测 clean/dirty/staged/untracked deploy guard 和失败不打 tag，不执行真实部署。
- `rg` 检查硬编码 home、个人 email/endpoint、`minpac`、旧 AI option 和直接写 nix.conf 的命令。

## 回滚

- Home baseline 和 option rename 保留一个短期兼容提交，消费者全部迁移后再删除兼容层。
- Nvim 文件拆分、LSP 修复、minpac 删除和 AI 删除各自独立回退。
- deploy guard 出错时可回退脚本提交；不得通过默认允许 dirty 来长期绕过。
- 静态检查初次接入允许 baseline 文件，不能为了通过检查删除有效配置或跳过 architecture。

## 完成标准

- profile 入口完整表达启用功能，通用 Home module 无隐藏 always-on 应用。
- Nvim 配置结构清晰，LSP package 无双清单，未配置 AI 不再显示为启用。
- deploy tag 默认可对应到实际部署的 clean commit。
- 维护命令不修改生成的 `/etc/nix/nix.conf`。
- `just chk` 覆盖 formatter、静态检查、脚本检查和三 host 关键断言。
