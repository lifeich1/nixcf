# 重构计划 03：主机元数据、端点与外部 package

本计划对应 `refactor-audit.md` 建议顺序的第 3 步：让 host registry 成为稳定主机元数据的
唯一来源，统一 proxy/cache/homelab endpoint，并让外部 package 通过显式 option 注入。
计划 01、02 完成且三 host 基线稳定后再执行。

## 目标

- hostname、username、architecture、Home profile、hardware modules 和 deploy target 只有一个
  权威定义。
- Pi DNS name、LAN address、代理端口、Attic endpoint/cache/public key 由类型化配置提供。
- “能解析 Pi”和“使用 Pi 作为代理”是两个独立状态。
- Gitea、Attic、Git/SSH、Proxychains、Home Manager 和运维命令不再复制 endpoint 字符串。
- Hobob、cp-guard、Agenix 等外部 package 使用 typed package option 或最小显式参数。
- `os/default.nix` 只聚合模块，基础系统、访问策略、Nix/cache 和 proxy 各有明确所有者。

## 设计决策

### Host registry

推荐新增根目录 `hosts.nix`，以一个小函数接收 `nixos-hardware`，返回三台主机的稳定数据：

- `system`、`username`、`homeModule`、`hardwareModules`。
- `deploy.target` 和 `deploy.tagPrefix`。
- 仅主机身份相关的数据，不包含服务 enable、文件系统、stateVersion 或 secret。

`flake.nix` 导入该 registry 并生成 `nixosConfigurations`，同时暴露不含 secret 的
`deployTargets` output 供 `justfile` 查询。host 的 `configuration.nix` 继续显式选择服务和
硬件策略，不进行全量生成化。

### Homelab endpoint

推荐新增 `os/homelab/` 类型化模块，字段至少包括：

- `pi.hostName`、`pi.lanAddress`、`pi.resolvable`。
- `proxy.socksPort`、`proxy.migrationPort`。
- `attic.scheme`、`attic.port`、`attic.cacheName`、`attic.publicKey`。

公开 key 和 endpoint 可以进入 Nix store；token、netrc 和签名 secret 只能引用计划 01 的
runtime secret path。Home Manager 通过集成模式的 `osConfig` 只读系统计算结果，不再接收
一份复制的 endpoint attrset。

保留 Home Manager 的“是否使用 Pi 代理”profile 选择，但移除可自由覆盖的 host/URL
内部 option。SOCKS URL 从 typed host/port 统一派生；Gitea migration port 必须保持独立。

### 外部 package

推荐让模块声明 `package` option，host/profile 在启用点传入对应 input 的当前架构 package。
不再为了单个 Hobob package 建立全局 overlay，也不把完整 `inputs` 传给通用模块。

## 范围

- `flake.nix`、新增 `hosts.nix`，以及 `justfile` 的 target 查询。
- 新增 `os/base/`、`os/access/`、`os/nix/`、`os/homelab/`，收缩 `os/default.nix` 和
  `host/common.nix`。
- `fool/default.nix` 的 proxy 派生逻辑。
- `os/gitea`、`os/proxychains`、`os/atticd`、`fool/attic`、Git/SSH 相关模块的 endpoint 引用。
- Hobob overlay、Hobob system module、cp-guard 和 Agenix package 注入边界。

本计划不收紧 firewall、不迁移服务用户/数据目录、不改变部署 dirty-tree 策略，也不修改
现有 endpoint 值。

## 基线

在实施前保存三台 host 的以下值：hostname、username、system、Home profile、hardware module
效果、root/user authorized keys、`networking.hosts`、proxy URL、Gitea domain/proxy、Attic
URL/cache/public key、deploy target、外部 package drvPath。

另保存 `just --list` 和三个 deploy recipe 展开的 target，但不执行部署或打 tag。

## 实施阶段

### 1. 提取 host registry

1. 将现有 `hosts` attrset 机械移动到 `hosts.nix`，字段值不变。
2. 用 registry key 直接设置 `networking.hostName`，删除只用于拼接的 `device`。
3. host 用户声明统一使用 registry 的 `username`，不改变实际用户名、home 或 group。
4. 将 `extraModules.beforeHome/afterHome` 合并为语义真实的 `modules`；先比较 list 类型 option
   的求值结果，确认不存在依赖注册顺序的差异。
5. 暴露最小 `deployTargets` output，`justfile` 只消费 target/tag，不读取完整 host 配置。

该阶段不移动 SSH key 和 endpoint，确保 registry diff 可独立审查。

### 2. 拆分系统基础职责

- `os/default.nix` 只保留 imports。
- `os/base/` 拥有 locale、timezone、基础 package、EDITOR、Zsh 和 OpenSSH daemon。
- `os/access/` 拥有 root authorized keys 和与主用户名有关的 access policy。
- `os/nix/` 拥有 Nix settings、substituter、trusted public key、GC 和诊断开关。
- `os/homelab/` 拥有 endpoint options、Pi hosts 解析和系统 proxy 派生。

`os/atticd` 纳入普通聚合入口，继续由 `fool.atticd.enable` 控制。Pi 不再在 flake modules 中
特殊导入它。每次移动只改变文件所有权，不修改 option 值。

### 3. 统一 SSH access policy

把过时的 `gtr5_pubkey` 名称改为角色语义，例如 `adminKeys` 或 `access.adminKeys`。同一 public
key 集合由一个 access policy 数据源提供，root access、Pi 用户 access 和 Agenix recipients
各自显式选择需要的 key，不通过名字偶然耦合。

Public key 不是 secret，但修改会影响远程恢复能力。比较三台主机最终 authorized key 集合，
确保只去重、不删除当前管理员入口。

### 4. 建立 homelab endpoint options

1. 在 `os/homelab` 声明带类型和端口范围检查的 options，默认值先复制当前有效值。
2. 由 `pi.resolvable` 控制 `networking.hosts`；Pi 本机可解析到 loopback/LAN 的策略由 host
   显式设置，不能同时维护 `extraHosts` 和共享 hosts entry。
3. 系统 proxy 和 Home proxy 从同一 SOCKS host/port 派生。
4. Gitea 只读取 migration proxy port；Attic 只读取 endpoint/cache/public key。
5. 为不合法组合添加 assertion，例如 `use-pi = true` 但 Pi 不可解析。

逐个消费者迁移，每个提交后 `rg` 旧 hostname、LAN address 和端口。最后删除旧
`fool.proxy.has-pi/use-pi` 系统 option 和 Home 内部 `tcp_url/socks5_url` 拼接。

### 5. 迁移外部 package

- 为 `os/hobob` 增加 `package` option，Pi 启用点传入
  `inputs.hobob.packages.${pkgs.stdenv.hostPlatform.system}.default`。
- 删除 `fool.hobob.overlay`、overlay import 和隐式 `pkgs.hobob`，前提是没有其他消费者。
- cp-guard module 增加 `package` option，由 GTR7 profile 或最小 shared package 参数提供。
- Agenix 使用其 NixOS module 已提供的 package/config 接口；若必须指定 CLI package，只传
  package，不传完整 input 集合。
- 每个 package option 使用 `types.package`，并在启用模块的两种 architecture 上定向求值。

package 注入只改变依赖边界，不在本阶段升级 revision、改启动参数或迁移服务用户。

### 6. 统一 deploy target 的消费方式

先让三个现有 recipe 通过 `nix eval --raw` 读取 `deployTargets.<host>.target` 和 tag prefix，
保持命令、顺序和 tag 行为不变。通用 deploy recipe、clean-tree guard 和 tag 加固属于计划
05，不在这里同时修改。

更新 root、host、os、fool 和 tools README，说明 registry 与 endpoint 的权威来源。

## 建议提交拆分

1. `:recycle: flake: extract host registry`
2. `:truck: os: split base and access modules`
3. `:truck: nix: move cache configuration`
4. `:recycle: homelab: centralize endpoints`
5. `:recycle: hm: consume system proxy endpoint`
6. `:recycle: hobob: inject package explicitly`
7. `:recycle: cp-guard: inject package explicitly`
8. `:recycle: deploy: read registry targets`

## 验证

- 每个提交运行 `just chk`，整批运行 `git diff --check`。
- 比较三 host 的 hostname、user、hardware、authorized keys、services 和 Home profile 基线。
- 比较所有 endpoint 的最终字符串值；允许定义位置变化，不允许 URL/端口变化。
- 定向求值/构建 Hobob 的 aarch64 package 和 cp-guard 的 x86_64 package。
- `rg` 检查旧设备参数、过时 key 变量名、散落 endpoint 和隐式 `pkgs.hobob`。
- 解析 `justfile` 并 dry-run 三个 deploy recipe；不得连接远端、switch 或创建 tag。

## 回滚

- registry、模块移动和 endpoint 消费者按提交独立回退，不影响计划 01 的 runtime secret。
- SSH policy 变更未在真实主机验证前不得删除旧入口。
- 外部 package 求值失败时恢复显式旧注入路径，不更新 input 或切换版本来掩盖问题。

## 完成标准

- 稳定主机元数据和 deploy target 只有一个来源。
- 非敏感 homelab endpoint 只有一个类型化来源，所有消费者均引用它。
- 通用模块不再依赖完整 flake inputs 或隐式个人 overlay package。
- 三台主机关键求值和 endpoint 值保持不变。
