# 重构计划 04：Firewall 与系统服务

本计划对应 `refactor-audit.md` 建议顺序的第 4 步：先把 firewall 从宽端口范围迁移到明确
allowlist，再逐个整理服务的 option、用户、目录、端口、secret 和状态所有权。该计划包含
真实网络与持久数据变化，必须在计划 01 至 03 完成后按主机、按服务实施。

## 目标

- 三台主机默认拒绝未声明的入站连接，不再开放 TCP/UDP `2048-65535`。
- 每个网络服务拥有自己的 listen/port/openFirewall option。
- firewall rule 不在通用 firewall、host 和 service module 三处重复维护。
- Hobob、Gitea、Syncthing、vlmcsd、VirtualBox 和桌面音频模块边界明确。
- 服务使用最小权限用户、声明式目录、可复现 image/package 和合理 hardening。
- 涉及持久数据的迁移都有备份、验证和 generation 回滚方案。

## 必须先解决的决策

| 项目 | 推荐决策 | 验证依据 |
|---|---|---|
| Firewall allowlist | 只开放实际监听且需要跨机访问的端口 | 三台主机 `ss`/firewall 现场清单 |
| KDE Connect | 使用上游 NixOS module 的 firewall 开关 | 桌面配对、发现和传输测试 |
| Syncthing | 拓扑放独立个人 data module | GTR7/XPS13 共用，非通用服务默认值 |
| XPS13 pro audio | 默认关闭 JACK 和高实时限制 | 用户确认没有专业音频工作流 |
| Hobob | 专用用户和 `/var/lib/hobob` | 确认程序不需要 root 和旧 `/opt` 数据 |
| vlmcsd backend | 删除 `cmd`，保留 OCI module | 当前 Pi 只使用 `nix` 分支 |
| 容器 image | 固定 digest | 在 aarch64 上验证可拉取和启动 |

若实际监听清单、Hobob 数据需求或 Syncthing 备份未完成，不得执行对应行为变化。

## 范围与顺序

服务按以下顺序独立迁移：firewall ownership、Attic、Gitea、Hobob、Syncthing、vlmcsd、
VirtualBox、桌面 collection，最后处理 Home Manager 容器。一个服务至少一个提交，不进行
全仓库 option 同时改名。

Xray secret 已在计划 01 处理；本计划只确认它的监听与 firewall 需求。hostname、endpoint
和 package 注入已在计划 03 完成，本计划直接消费这些 options。

## 实施阶段

### 1. 建立真实端口清单

在每台在线主机记录 TCP/UDP listen socket、bind address、所属 process/unit、是否需要 LAN
访问、客户端来源和临时开发用途。重点核对：SSH、Xray、KDE Connect、Syncthing、Gitea、
Attic、Hobob、vlmcsd 和录播容器。

清单只记录端口和 unit，不记录连接 payload、secret 或用户数据。临时开发端口不进入默认
allowlist；需要时通过短期 host override 或明确维护命令开启。

### 2. 先迁移 firewall rule 所有权

保持 `non-strict` 暂时开启，先为每个服务建立 typed `port` 和 `openFirewall`：

- Gitea、Attic、Hobob 和 vlmcsd 由各自 module 添加端口。
- Syncthing 和 KDE Connect 优先使用上游 module 的 firewall options，并求值确认具体范围。
- SSH 继续由 NixOS OpenSSH module 管理。
- Xray 根据实际 bind address 决定是否需要入站 rule；loopback-only 不开放。
- 删除 `serve-hobob`、`serve-friedegg` 等按应用重复命名的 firewall options。

比较迁移前后的最终 `allowedTCPPorts`、`allowedUDPPorts` 和 ranges。此阶段宽范围仍在，因此
不会先造成网络中断。

### 3. 逐主机关闭宽范围

1. Pi 首先切换为 strict allowlist，部署前确认本地控制台或可靠 SSH 恢复路径。
2. XPS13 其次切换并测试移动网络、Syncthing 与 KDE Connect。
3. GTR7 最后切换并测试桌面服务、虚拟化和远端部署路径。
4. 三台验证完成后删除 `fool.firewall.non-strict` option 和宽 range 实现。

每台主机单独提交或至少保留单独 generation。远端 `switch` 失败时停止后续主机，不用一次
部署掩盖部分失败。

### 4. 整理 Attic service options

在不改变计划 01 凭据路径的前提下，为 `fool.atticd` 增加 listen address、integer port、
cache/retention 和 package options。服务端 module 拥有 firewall rule；客户端从计划 03 的
endpoint 读取 URL/cache name。

chunking 参数与现有数据格式有关，本轮保持原值。修改后验证旧 NAR 可读、新 NAR 可上传、
GC 配置未变化，并确认 restart 不改变数据库/存储目录。

### 5. 整理 Gitea

- 为 domain、migration proxy、registration policy 和 `openFirewall` 建立 options。
- 删除失效的 `mailer.SENDMAIL_PATH` workaround，先用当前 NixOS option 求值确认不再需要。
- domain/proxy 从计划 03 endpoint 读取，端口由 Gitea module 自己拥有。
- 保持数据库、repository、LFS 路径和现有用户不变。

部署前备份 Gitea 数据库和 repositories；验证 Web、SSH/HTTP clone、LFS 和 GitHub migration。

### 6. 迁移 Hobob 到专用服务

- 将 option 统一为 `fool.hobob.enable`，保留计划 03 的 `package` option。
- 建立专用 system user/group，使用 `StateDirectory=hobob` 或显式 `dataDir`。
- 增加 listen address、integer port、`openFirewall` 和 network-online 依赖。
- 使用 `ExecStart = lib.getExe cfg.package`，增加程序兼容的 systemd hardening。
- 先检查 `/opt/hobob` 是否存在有效数据；有数据时停服备份并一次性迁移到新目录。

若程序确实需要 root 或写任意路径，停止迁移并记录最小 capability/路径需求，不保留无说明
的 root service。

### 7. 拆分 Syncthing wrapper 与拓扑

通用 `os/syncthing` 只保留 enable、user、dataDir/configDir 和上游服务 options。devices、
folders、folder id 和 receive-only 方向移动到单独的个人 topology data module，由 GTR7 与
XPS13 host 显式导入。

迁移前导出运行态配置并备份 receive-only 目录。第一阶段保持 `overrideFolders = false`、
`overrideDevices = false` 和所有 folder id/path/type 不变；确认一致后，再单独决定是否让 Nix
完全接管拓扑。不得在结构迁移提交中更改同步方向或删除设备。

### 8. 简化 vlmcsd 和容器

- 删除未使用的 `cmd` 分支和 `invokeType`，保留 NixOS OCI container 声明。
- image 固定到已验证 digest，port 使用 integer option，映射字符串由 module 生成。
- module 拥有 Podman backend、restart policy 和 firewall rule。
- 在 Pi/aarch64 上先 pull 和验证新 image，再切换；image pin 单独提交。

`fool/bililiverecorder` 另行增加 image、dataDir、listen/host port 和访问策略 options，并把
environment value 统一为字符串。录制数据目录和 image 版本不能在同一提交迁移。

### 9. VirtualBox 与桌面 collection

- VirtualBox host option 接收用户列表或从主用户名派生 `vboxusers`，增加 assertion，删除
  host 文件中的重复 group 约定。
- 将 `fool.collections.gtr` 拆为 `desktop`、`audio`、`pro-audio`；GTR7 明确启用 pro audio，
  XPS13 按决策启用或关闭。
- TeamViewer package/service 所有权只保留系统或用户层的一处。
- Plasma 的 Calibre workaround 和字体 collision 单独验证、单独提交，不混入 firewall。

## 建议提交拆分

1. `:recycle: firewall: move rules to services`
2. `:boom: firewall: default to deny`
3. `:recycle: atticd: expose service options`
4. `:recycle: gitea: own endpoint and firewall`
5. `:recycle: hobob: run dedicated service`
6. `:truck: syncthing: separate topology data`
7. `:coffin: vlmcsd: remove command backend`
8. `:pushpin: vlmcsd: pin container image`
9. `:recycle: virtualbox: own user groups`
10. `:recycle: desktop: split audio profiles`

## 验证

- 每个提交运行 `just chk`，服务重构后定向构建对应 host toplevel。
- 求值三台主机最终 firewall rule，确认不存在宽 range 和重复端口所有者。
- 每次真实部署前保存当前 generation；部署后检查 unit、socket、journal 和应用级健康检查。
- Pi 验证 SSH、Attic、Gitea、Hobob、vlmcsd；桌面验证 Syncthing、KDE Connect、Xray。
- Hobob/Gitea/Syncthing 的数据迁移执行备份恢复演练或最小抽样校验。
- 容器验证 architecture、digest、restart 和 reboot 后自动启动。

部署命令会连接远端并打 tag，必须获得用户明确授权；只完成本地求值不能宣称本计划完成。

## 回滚

- Firewall 变更保留主机控制台或上一 generation，失联时从本地选择旧 generation。
- 服务目录迁移在确认稳定前保留只读旧目录和备份，不让新旧 unit 同时写同一数据。
- container image 保留上一 digest；数据格式发生升级时不能只回退 image，必须使用对应备份。
- Syncthing 回滚保持 folder id 和 receive-only 方向，避免回退触发重新索引或反向覆盖。

## 完成标准

- 三台主机没有默认高端口宽放行，所有必要入站连接都有明确所有者。
- 所列服务均使用 typed options、明确用户/目录/端口和可复现 package/image。
- 持久数据和真实网络路径已经逐主机验证。
- 每项行为变化均可定位到独立提交和 generation。
