# nixcf 重构审查

审查基线：`2e14490`（2026-08-30）。本审查覆盖 `flake.nix`、三台主机与 Home
Manager profile、`os/`、`fool/`、`secrets/`、`justfile` 和 `tools/` 中的已跟踪配置。
硬件扫描文件只检查了接入边界，不建议把自动生成内容纳入普通重构。

当前 `just chk` 全部通过。因此下列事项主要针对安全边界、配置所有权、部署可追溯性和
长期维护成本，不表示当前配置无法求值。文中不记录任何 token、密码或私钥内容。

## 结论

建议按以下顺序推进：

1. 立即轮换并迁移已进入 Git/Nix store 的 Attic 凭据，同时收紧 Xray secret 权限。
2. 删除已确认的死 input、死参数和未启用模块，保持求值结果不变。
3. 统一主机元数据、代理/缓存端点和外部包注入方式。
4. 收紧 firewall 默认值，再逐个整理服务模块的用户、目录、端口和 secret 所有权。
5. 整理 Home Manager 基线、Nvim 和运维脚本，最后增加静态检查与部署保护。

不应把这些事项压进一个提交。每个阶段都应先保存三台主机的关键求值结果，再以小提交
迁移，避免把安全策略变化、模块改名和服务状态迁移混在一起。

## P0：安全边界

### 1. Attic 凭据离开 Git 和 Nix store

**证据**

- `host/common.nix:44-49` 直接生成带认证材料的 netrc；该内容会进入 Git 历史和
  world-readable Nix store derivation。
- `os/atticd/atticd.env` 含服务端签名 secret，`os/atticd/default.nix:44` 又通过普通
  `environment.etc.source` 部署它。
- `fool/attic/attic-client.toml` 含客户端 token，并由 `fool/attic/default.nix:36` 作为
  Home Manager store source 部署。
- `host/nixos-pi4b/atticd.env` 与 `os/atticd/atticd.env` 完全相同，但前者没有引用者。
- 上述材料自 2024 年起已存在于历史中，不能通过只删当前文件完成处置。

**目标**

- 先轮换 Attic 服务端签名 secret 和所有客户端 token；旧值按已泄露处理。
- 用 Agenix 管理服务端 environment file、客户端 token/netrc，并在运行时从
  `/run/agenix` 或 systemd credential 读取，不把解密结果复制进 store。
- 为每台客户端签发独立、最小权限 token；Pi 服务端不应无条件继承桌面客户端凭据。
- 删除未引用的 `host/nixos-pi4b/atticd.env`，当前树中移除其他明文认证文件。
- 轮换完成后再决定是否重写 Git 历史；历史重写不能替代凭据轮换。

**验收**

- `git grep` 找不到明文凭据，生成的 netrc/Attic config 指向 `/run/agenix` 等运行时路径，
  而不是 `/nix/store`。
- 解密文件权限、owner 和服务用户匹配；三台机器分别验证 substituter，GTR7 验证
  `attic watch-store`，Pi 验证上传、读取和服务重启。

### 2. 修正 Agenix identity 与解密文件权限

`secrets/default.nix:30` 使用 `/home/${username}/.ssh/id_ed25519` 作为系统 secret 的解密
identity。这把系统 activation 绑定到普通用户 home 和登录私钥，复用了本应分离的身份
边界。应改用 host SSH key 或专用 age identity，并同步 rekey `secrets/secrets.nix` 中的
接收者；迁移必须保证新旧 identity 有重叠期，避免远端主机失去密码和 Xray 配置。

`secrets/default.nix:23-28` 把 Xray 配置设为 mode `444`。当前求值显示 Xray 使用
`DynamicUser=true` 和 systemd `LoadCredential`，因此源文件可保持 root-only，由 PID 1
安全传给服务。应改为 `0400`，并确认三台主机重启 Xray 后仍能读取 credential。

`fool.secrets.pass` 目前是任意 nullable string，再由它动态拼接 secret 名和文件。应改为
host registry 中的明确 secret 声明或 typed password secret option，避免文件选择逻辑与
用户创建逻辑隐藏耦合。

### 3. Firewall 改为默认拒绝

`os/firewall/default.nix:8-34` 令 `non-strict` 默认开启。当前求值结果是三台机器都开放
TCP/UDP `2048-65535`；Pi 即使声明了 1688、3000、3731，宽范围规则仍使这些细粒度规则
失去大部分意义。

迁移时先列出实际监听端口和 KDE Connect/Syncthing 所需范围，再把宽范围改为默认关闭。
服务模块应通过各自 `openFirewall` option 或 host 中的明确规则拥有端口，不能同时在
`os/firewall`、服务模块和 host 三处维护。此项是行为变化，需逐主机部署和连通性测试。

## P1：结构与所有权

### 4. 清理 flake 的死依赖和死参数

已确认以下值没有消费者：

- `nixpkgs-stable` input、`pkgs-stable` import 和 XPS13 参数。
- host registry 的 `hasPi` 及传入模块的 `has_pi`。
- `all_proxy` 的固定值和 XPS13 形参。
- 传入 `_module.args` 的 `nixos-hardware`；input 本身仍用于选择硬件模块，不能删除。

进一步把 `system` 的唯一 Home Manager 用途改为
`pkgs.stdenv.hostPlatform.system`，并只向 Home Manager 传它实际需要的参数或 package，
不要把完整 `inputs`、NixOS 专用参数和 Home Manager 参数放在同一个 `args` attrset。

`extraModules.beforeHome/afterHome` 目前表达了并不存在的强顺序语义。Nix module 主要依赖
merge priority，而不是注册先后；应在确认无 list-order 差异后合并为单一 `modules` 字段，
把共同模块列表写成清晰的固定顺序。

### 5. 让 host registry 成为唯一主机元数据源

主机名、用户名、远端地址、Home profile 和硬件 modules 分散在 `flake.nix`、host 文件和
`justfile`：

- `device` 只用于拼接 `networking.hostName`。
- GTR7/XPS13 用户仍硬编码为 `fool`，没有一致使用 registry 的 `username`。
- `gtr5_pubkey` 名称已过时，同一批 SSH public key 还散落在 `os/default.nix` 和
  `secrets/secrets.nix`。
- 三个部署 target 又在 `justfile` 单独维护。

保留一个小型 host registry，但不要把所有 host 配置生成成复杂函数。registry 只保存
稳定元数据；host 文件继续负责硬件和服务选择。SSH 授权 key 应改为有语义的 access
policy 数据，主机名可直接使用 registry key，部署脚本通过统一 host/target 表调用一个
通用 rebuild recipe。

### 6. 统一代理和 homelab 端点模型

当前代理状态存在三套表达：NixOS 的 `fool.proxy.has-pi/use-pi`、Home Manager 的
`fool.proxy.use-pi/host/port`，以及已经失效的 flake `hasPi`。`my-pi`、
`192.168.3.6`、10809、10819 和 8080 又散落在多个模块和 `justfile`。

应定义一个小型、类型化的 homelab endpoint 配置，至少区分：

- DNS name 与 LAN address。
- SOCKS client port 与 Gitea migration proxy port；两者不能因名称相似而盲目合并。
- Attic endpoint、cache name 和 public key。
- “可解析 Pi”与“使用 Pi 代理”两个独立状态。

NixOS 计算系统端配置，再把必要的只读结果传给 Home Manager。删除 internal
`tcp_url/socks5_url` 的手工拼接重复，并让 Gitea、Proxychains、Git、SSH 和运维脚本引用
同一份端点数据。

### 7. 统一外部 package 的注入方式

- `cp-guard` 直接从 `inputs` 取 package，且其 flake 当前锁入另一份 nixpkgs。若上游兼容，
  增加 `inputs.nixpkgs.follows = "nixpkgs"`；否则明确记录隔离原因。
- Hobob 先通过条件 overlay 生成 `pkgs.hobob`，系统模块和用户模块再依赖这个隐式包名。
  应给模块提供 typed `package` option，默认取当前架构 input package；只有确实需要全局
  `pkgs.hobob` 时才保留 overlay。
- Agenix package 通过 `all.inputs` 和 `all.system` 读取。改为显式 package 参数或使用
  已有 package set，避免模块接收整个 flake inputs。

每个外部 package 都应在 aarch64 和 x86_64 的启用 host 上求值；不能假定 input 对所有
架构都有同名 output。

### 8. 拆分 `os/default.nix` 的职责

该文件同时承担模块聚合、基础系统包、主机名/locale、root SSH access 和系统代理 option。
建议拆为：

- `os/default.nix`：只聚合模块。
- `os/base/`：locale、基础程序和 SSH daemon。
- `os/access/`：root authorized keys 与 sudo policy。
- `os/proxy/`：系统代理端点和 hosts 解析。

同时把 `os/atticd` 纳入普通聚合入口，由 `fool.atticd.enable` 控制；它不需要在
`flake.nix` 为 Pi 特殊导入。`vim/wget/git` 在 `os/default.nix` 与
`os/collections/default.nix` 重复，应只保留一个基础集合。

`host/common.nix` 中的 Nix cache、GC、调试和 Attic 认证也应拆到专用 `os/nix/` 模块。
`trace-verbose = true` 应成为临时诊断开关；标记为 outdated 的 mirror 应在独立连通性验证
后删除，substituter、public key、netrc 和 Pi Attic 端点继续作为一个整体评审。

### 9. 重新划分桌面 collection

`fool.collections.gtr` 同时被 GTR7 和 XPS13 启用，实际包含 NetworkManager、Plasma、
PipeWire/JACK 和 guitarix 的高 `memlock/rtprio` 限制。名称和职责都过宽。

建议拆成 `desktop.enable`、`audio.enable` 和可选 `pro-audio.enable`，由两个 host 明确选择。
这也能避免轻量笔记本因为“桌面”隐式获得专业音频限制。`services.teamviewer.enable` 与
Home package 的所有权也应统一，避免同一应用在系统层和用户层重复表达。

### 10. 修正 Plasma overlay 的 package 组合方式

`os/plasma/default.nix:55-69` 的 overlay 在函数内部引用外层 `pkgs`，并只手工链接 Calibre
的一个 binary 和 `share`。这会绕过 overlay 的 `final` package set，也可能遗漏 Calibre
随包提供的其他 executable。

先验证当前 nixpkgs/Wayland 下 workaround 是否仍需要；需要时使用 `final.symlinkJoin`、
`final.makeWrapper` 和完整原包，或采用上游 package 支持的 override。NUR 仅被桌面字体使用，
也应考虑只在桌面 host 导入，而不是让 Pi 全局承载该 module/input 依赖。

同一模块已注明 `ttf-wps-fonts` 与 `ttf-ms-win10` 存在 collision，不应长期保留“已知冲突但
同时安装”的状态。应选择单一字体来源或明确拆除冲突文件，并用 `fc-list` 验证实际字体。

## P1：服务模块

### 11. Attic 服务与客户端

除 P0 的 secret 迁移外，还应把 listen address、port、cache name、retention 和 package
暴露为 typed options。客户端 service 使用 `lib.getExe`/明确 subcommand，服务端端口由
本模块拥有。不要再让 `host/common.nix`、`os/atticd` 和 `fool/attic` 通过字符串约定耦合。

### 12. Hobob

`os/hobob/default.nix` 默认以 root 运行，硬编码 `/opt/hobob`，却不创建或声明该目录；
service 名还叫 `programs-hobob`。应改为标准 `fool.hobob.enable`，提供 `package`、`user`、
`dataDir`/`StateDirectory` 和端口 option，使用专用用户及合理 hardening，并声明
`network-online.target` 依赖。用户态 Hobob module 当前没有启用者，且保留 14 行注释服务，
应删除或在确认需求后重新设计，不能继续与系统 module 共用含糊命名空间。

### 13. Gitea

`os/gitea/default.nix` 硬编码域名和 migration proxy，并用无效
`mailer.SENDMAIL_PATH` 规避旧问题。应先确认该 workaround 是否仍需要并删除失效配置，
再为 domain、proxy 和 `openFirewall` 建立 option。`serve-friedegg` 命名应改为 Gitea 语义，
端口归 Gitea module 所有。

### 14. Syncthing

`os/syncthing/default.nix` 把可复用 service wrapper、用户 home 路径、所有设备 ID 和目录
拓扑放在一个 133 行模块中，但它只服务两台特定主机。应保留一个小型通用 wrapper，把
devices/folders 数据移到明确的个人拓扑文件或 host/profile 数据中。公共目录不要通过
`/home/${username}` 猜测，优先从用户/home 配置导出。迁移时保持
`overrideFolders=false`、`overrideDevices=false`，并对 receive-only 目录做数据备份验证。

### 15. vlmcsd 与容器

Pi 只使用 `invokeType = "nix"`，`cmd` 分支是未使用的第二套 service 实现。若没有实际的
代理拉取需求，应删除 cmd 分支并直接使用 OCI module；否则把 option 改为 `backend` 并让
两种实现共享 image、ports、proxy 和 restart policy。镜像应固定 digest，而不是
`latest`，端口使用 integer option，并提供 `openFirewall`。

`fool/bililiverecorder` 同样应把 image digest、dataDir、listen/host port 和访问策略做成
option；环境变量使用明确的字符串值。容器更新要与数据格式验证分开提交。

### 16. VirtualBox 与 sudo

VirtualBox host 启用后还要求 host 手工把用户加入 `vboxusers`，这是跨文件不变量。模块应
接收 users 或使用主用户名自动维护 group，并添加 assertion。未使用的 guest mode 可删除，
或保留为独立、命名一致的 `guest.enable`。

`fool.sudo.extra-options` 只是为了内部拼接 NOPASSWD，不应成为公开 option。直接在
`mkIf cfg.nopass` 中构造 rule；需要细粒度命令时新增独立 rule，不扩张现有 `ALL`。

## P2：Home Manager

### 17. 明确 always-on 基线与可选模块

`fool/default.nix` 导入后会无条件启用 Bash、Git/Difftastic、GPG agent、SSH、Nvim、misc
工具和部分 XDG 配置；其他模块则使用 `enable`、动作型布尔值或“非 null 即启用”。这使
profile 很难仅从入口看出最终功能。

建议把真正的跨主机基线移到 `home/common.nix`，可选模块统一采用
`fool.<name>.enable`。不要机械地给每个三行配置增加 module：Cargo config 等只被桌面
公共 profile 使用的薄封装，可直接放在 `home/desktop-common.nix`。命名同步整理：
`ctrl-config`、`watch-store`、`with-skim`、`configFile`、`invokeType` 应遵循一致的
kebab-case option 层级。

### 18. 消除 Home 模块的隐藏依赖

- Alacritty 不应隐式启用 Zellij；Zellij 属于 profile 选择。
- Fastfetch 配置 module 不安装 Fastfetch，实际依赖 Zsh module 提供 package。改用 Home
  Manager 的 `programs.fastfetch` 或让 module 自己完整拥有 package 与 config。
- Zsh 的 skim integration 与 `fool.zsh.enable` 没有关联，且 `skim/eza` 在基础包和 Zsh
  中重复。建立单一 package owner，并对无效组合加 assertion 或合并开关。
- `com-lemonade` 的 generated script 应把 `openssh` 加入 `runtimeInputs`，加强后台进程
  cleanup 和启动失败处理，避免依赖系统 PATH 的偶然状态。
- cp-guard/Attic 用户服务应使用 `lib.getExe`、可配置 package、明确 restart policy 和
  runtime directory，而不是重复手写松散字符串。

### 19. 把个人身份和环境数据移出通用模块

Git identity 默认值、SSH 内网/business host、Nvim 邮箱缩写和 `/home/fool/opt/...` provider
路径都写在通用 module 中。应把 identity 和私有 endpoint 数据放入 profile 数据层，Nvim
provider 改用 package option 或 `$HOME` 派生路径。这样 Pi profile 不会求值桌面用户的
路径和身份假设，也能减少未来新增用户时的修改面。

### 20. 删除无使用者和命令式安装器

以下功能当前没有 profile/host 启用：

- `fool.kitty.enable`。
- 用户态 `fool.hobob.enable`。
- `fool.xray.installer`。
- `fool.virtualbox.guest-enable`。

其中 Xray installer 会从 Home Manager command 直接写 `/etc/systemd/system`，与 NixOS 的
`services.xray` 冲突，应优先删除。其余模块先确认近期需求：没有明确消费者就删除，未来
需要时从当前上游 API 重新实现。注释掉的 Hobob service 和旧 input mirror 行也应删除，
历史由 Git 保存。

### 21. Nvim 配置继续按行为拆分

近期 Nixvim 迁移已经拆出 LSP 和 AI，但 `fool/nvim/base.nix` 仍有 378 行，混合 plugin、
编辑选项、gitmoji UI、竞赛缩写、provider 路径和 remote clipboard。建议按
`plugins.nix`、`editor.nix`、`keymaps.nix`、`workflow.nix` 拆分；拆分只移动定义，不同步
改变键位或 plugin。

需要同时处理的具体问题：

- LSP server 全部设为 `package = null`，另在 `home.packages` 维护第二份 package 清单，
  已出现配置 `clangd` 却安装 `ccls` 的漂移。让 Nixvim server option 拥有 package，或从
  一份 server 定义生成两边。
- Python LSP 锁到 `python312Packages`，应使用当前 package set 的稳定别名或显式 option。
- minpac input 只支持空的 legacy 管理块和三个命令；nixpkgs 当前没有对应 plugin，但若
  已无非 Nix plugin，应整体删除 input、plugin 和命令。
- `fool.nvim.ai` 只安装 Avante plugin，不执行 setup。要么完成配置和 secret 接入，要么
  删除该开关，避免“已启用但不可用”的状态。
- provider 绝对路径与个人 abbreviation 移入 profile/local addon；通用 base 保持跨用户。

## P2：运维与验证

### 22. 部署前验证工作区可追溯

`just rebuild-*` 在成功后给当前 commit 打 tag，但没有拒绝 dirty worktree。Nix 可以部署
未提交的 tracked 内容，此时 tag 指向的 commit 并不等于已部署 closure。通用 deploy
recipe 应在构建前检查 tracked/staged/untracked flake source 状态，或明确记录 dirty
revision；默认推荐拒绝 dirty 部署。

三个 rebuild recipe 只应保留 target 差异，公共的 `nixos-rebuild`、日志参数和 tag 行为
由一个 recipe 实现。继续保持“远端 switch 返回非零则不打 tag”的现有语义。

### 23. 停止直接修改生成的 `/etc/nix/nix.conf`

`disable-commu/cfg-rollback` 直接备份和改写 NixOS 生成文件，可能被下一次 switch 覆盖，
也可能把临时状态遗留到后续部署。优先使用 `/run` 下的 nix-daemon drop-in、命令级
`--option substituters` 或 NixOS specialisation 表达临时策略，并保证 trap 恢复。

`tools/use-proxy.portable.sh` 与 `just proxy` 重复，而且使用固定 `/tmp` 文件名、非 `mkdir -p`
和无 cleanup。若没有独立分发需求就删除；需要保留时改为调用同一脚本实现，并使用
`mktemp`、trap、`install -D` 和严格 shell mode。

### 24. 增加静态检查和关键求值断言

当前 `just chk` 只验证 flake/NixOS configuration 求值，没有 formatter、dead-code、module
API 或服务策略回归检查。建议逐步加入：

- `nixfmt` formatter check。
- `statix` 和 `deadnix`，先建立可接受的 baseline，再逐项清零。
- 三个 host 的关键 eval：architecture、username、home profile、kernel/bootloader、firewall、
  secret mode、服务 enable 状态和外部 package availability。
- 重要脚本的 `shellcheck`；just recipe 至少做解析检查。
- 重构服务时定向构建对应 toplevel；Pi 的完整 kernel build 成本高，可把纯求值与完整构建
  分层执行。

## 推荐实施批次

### 批次 A：凭据应急处理

轮换 Attic secret/token，迁移到 Agenix，删除重复 env，收紧 Xray mode。该批次不做 option
改名。验收 secret 权限、Attic 读写、Xray 和三台主机求值。

### 批次 B：无行为清理

删除 stable input、死参数、未使用特殊参数、重复基础包、命令式 Xray installer 和确认无
需求的死模块；让 cp-guard follows 主 nixpkgs。用重构前后的关键 `nix eval --json` 做 diff。

### 批次 C：主机与端点模型

整理 registry、用户名/SSH access、proxy/cache endpoint 和 deploy target；合并 flake module
字段。保证三个 host 的 hostname、home user、authorized keys、proxy URL 和服务开关不变。

### 批次 D：策略与服务

先收紧 firewall，再逐个处理 Attic、Hobob、Gitea、Syncthing、vlmcsd、VirtualBox。每个服务
独立提交，涉及状态目录或容器镜像时准备回滚 generation 和数据备份。

### 批次 E：Home 与编辑器

明确 Home baseline，修复隐藏依赖，迁移 identity/endpoint 数据，最后机械拆分 Nvim 并
修正 LSP package ownership。键位、插件和 CLI 集合变化应与文件拆分分开提交。

### 批次 F：运维护栏

统一 deploy recipe、拒绝 dirty tag、替换 `/etc/nix/nix.conf` 直接修改，接入 formatter、
lint、shellcheck 和关键 eval checks。

## 待决策项

实施前需要明确以下策略；它们不能由机械重构代替：

1. 是否保留 Git 历史中的旧 secret。无论答案如何，必须先轮换。
2. Firewall 实际允许清单，尤其 KDE Connect、Syncthing discovery 和临时开发服务。
3. XPS13 是否确实需要 JACK 和专业音频资源限制。
4. Hobob 的运行用户、持久目录、监听端口和是否必须访问 root 资源。
5. vlmcsd 是否仍需要 `cmd` 代理拉取分支；不需要则删除。
6. Syncthing 拓扑是共享个人数据还是 host 私有数据，决定放在专用 data module 还是 host。
7. 未启用的 Kitty、VirtualBox guest 和用户态 Hobob 是否有近期使用计划。
8. Avante 是否准备完成 provider/secret 配置；否则移除当前 AI 开关。
9. 部署是否允许 dirty tree。推荐默认禁止，另设显式 `--allow-dirty` 逃生路径。

## 不建议纳入本轮重构

- 不修改 `hardware-configuration.nix`、`system.stateVersion` 或 `home.stateVersion`。
- 不回退 Pi 的 nixos-hardware kernel、extlinux、device-tree overlay 或 firmware activation
  选择；这些属于已验证硬件策略。
- 不为三个相似终端强造共享抽象；先消除隐藏依赖和统一 option 规范即可。
- 不把三个 host configuration 全部生成化。少量显式 host 文件比高度参数化函数更容易
  审查硬件和服务差异。
- 不在结构拆分提交中升级 flake inputs、容器镜像或应用版本。
