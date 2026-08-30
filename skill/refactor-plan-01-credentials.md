# 重构计划 01：凭据与 secret 边界

本计划对应 `refactor-audit.md` 建议顺序的第 1 步：轮换并迁移已经进入 Git/Nix store 的
Attic 凭据，同时修正 Agenix identity 和 Xray secret 权限。该工作是后续结构重构的前置
条件，不能与 option 改名、服务目录迁移或 input 更新放在同一批提交中。

## 目标

- 旧 Attic 服务端签名 secret 和客户端 token 全部失效。
- Attic 服务端环境、Nix daemon netrc 和 Attic 客户端配置只在运行时解密。
- 每台客户端使用独立的只读 token，GTR7 watch-store 使用独立写入 token。
- 系统 secret 使用 host SSH key 或专用 age identity，不依赖普通用户登录私钥。
- Xray 解密文件保持 root-only，并继续通过 systemd credential 交给动态用户服务。
- 当前 Git tree 和新生成的 Nix store path 不再包含认证材料。

## 前置决策

| 项目 | 推荐决策 | 实施门禁 |
|---|---|---|
| Agenix identity | 使用每台主机的 `/etc/ssh/ssh_host_ed25519_key` | 先从三台真实主机安全取得对应 public key |
| Attic token | 每台主机一个 pull token，GTR7 另有一个 push token | 先确认当前 Attic 版本的 token 签发和撤销命令 |
| Git 历史 | 先轮换，历史重写另立计划 | 不允许用历史重写替代轮换 |
| 维护窗口 | 接受 Attic 短时不可用 | 服务端签名 secret 切换后再签发并部署新 token |
| Xray owner | 保持 `root:root`、mode `0400` | 先确认当前 unit 仍使用 `LoadCredential` |

任何 secret 值都不得出现在 shell history、计划文档、commit message、构建日志或普通临时
文件中。编辑密文只使用 Agenix；涉及现有明文文件时只删除或替换引用，不在 agent 输出中
读取其内容。

## 范围

主要修改：

- `secrets/secrets.nix`、`secrets/default.nix` 和新增的 `.age` 文件。
- `host/common.nix` 的 Nix cache/netrc 配置。
- `os/atticd/default.nix` 及其 README。
- `fool/attic/default.nix` 及其 README。
- 三台 host README 和 `secrets/readme.md` 中的运维说明。

本计划不修改 Attic 端口、保留期、cache 名称、服务用户或部署脚本；这些分别属于计划 03、
04 和 05。

## 实施阶段

### 1. 保存无敏感信息的基线

记录三台主机以下求值结果：Agenix secret 名称、目标路径、owner/mode、Attic/Xray unit 是否
启用、Nix substituter URL 和 netrc-file 路径。只记录路径和布尔值，不记录文件内容、token
或环境变量值。

在真实主机记录服务状态和可逆操作：Pi 的 `atticd`、三台主机的 `xray`、GTR7 的
`attic-watch-store`。确认上游公共 substituter 可用，避免 Attic 维护窗口阻断部署。

### 2. 迁移 Agenix identity

1. 将三台 host public key 加入 `secrets/secrets.nix`，暂时保留现有用户 key 接收者。
2. 使用 Agenix rekey 当前密码和 Xray secret，使新旧 identity 在过渡期都能解密。
3. 将 `age.identityPaths` 改为 host key 优先、旧用户 key 兜底。
4. 逐主机部署并验证 activation 能解密已有 secret。
5. 删除旧用户 identity path 和旧接收者，再次 rekey、部署并验证。

这两个接收者变更必须分成两个提交和两个部署点。远端主机未验证新 identity 前，不得删除
旧接收者。

### 3. 收紧 Xray secret

将 `xray-config` 的 mode 从 `444` 改为 `0400`，保持 `symlink = false` 和当前目标路径不变。
求值确认 Xray unit 的 credential source 指向该文件，随后逐主机 restart 并检查 unit、监听
端口和代理连通性。该变更单独提交，便于在 credential 假设不成立时回退。

### 4. 声明新的 Attic runtime secrets

按用途建立密文，不复用一个包含全部权限的文件：

- Pi：Attic 服务端 environment file。
- GTR7、XPS13、Pi：各自的只读 netrc。
- GTR7：watch-store 使用的 Attic client config 或写入 token 文件。

服务端 secret 只授权给 Pi host key；客户端 secret 只授权给对应 host key。NixOS 声明必须
显式设置 owner、group 和 `0400`，并使用稳定的 `/run/agenix/...` path。GTR7 的用户态配置
应由 `fool` 可读，但不得对其他本地用户可读。

### 5. 切换运行时引用

- `services.atticd.environmentFile` 直接引用 Agenix runtime path，删除
  `environment.etc.<name>.source`。
- `nix.settings.netrc-file` 指向各 host 的 Agenix runtime netrc，不再用 Nix 字符串生成文件。
- GTR7 的 Attic config 使用 Home Manager `mkOutOfStoreSymlink` 或 unit 的显式 runtime
  config 参数，不能把 `/run/agenix` 文件重新复制进 store。
- watch-store 的 executable 使用 `lib.getExe`，cache 名暂时保持不变。
- 为 secret path、启用 host 和 owner 增加 assertion，防止 Pi 意外获得桌面 push token。

先完成求值和 store 检查，再进入凭据轮换维护窗口。

### 6. 轮换并上线 Attic 凭据

1. 备份 Attic 数据和服务配置元数据，不复制旧 secret 到普通备份。
2. 切换 Pi 的服务端签名 secret 并重启 Attic。
3. 使用已安装版本支持的管理命令签发三份 pull token 和一份 GTR7 push token。
4. 立即通过 `agenix -e` 写入对应密文，部署 GTR7、XPS13 和 Pi。
5. 验证每台主机可从 cache 读取，验证 GTR7 可上传，验证 pull token 无上传权限。
6. 撤销全部旧 token；无法精确撤销时，以新签名 secret 使旧 token 整体失效。

此阶段需要真实主机和明确部署授权。代码准备完成不代表轮换完成。

### 7. 删除明文和重复文件

删除 `os/atticd/atticd.env`、`host/nixos-pi4b/atticd.env`、
`fool/attic/attic-client.toml`，并移除所有 source 引用。更新 README，只描述 secret 名称、
owner、运行时路径和轮换流程，不写示例 token。

最后单独决定是否重写 Git 历史。若重写，需要冻结推送、通知所有 clone 重新同步，并确认
远端、备份和 fork 的处置；该操作不属于本计划的普通代码提交。

## 建议提交拆分

1. `:wrench: secrets: add host age identities`
2. `:wrench: secrets: drop user age identity`
3. `:rotating_light: xray: restrict secret mode`
4. `:ambulance: attic: move credentials to agenix`
5. `:fire: attic: remove plaintext credential files`

每个提交只包含对应代码和文档。密文变更可以提交，但 commit message 和 diff 审查不得输出
解密内容。

## 验证

- 对每个阶段运行 `just chk` 和 `git diff --check`。
- 求值三台主机的 identity path、secret path、owner、mode、service enable 和 netrc-file。
- 检查生成 closure 中没有旧的明文配置文件名，也没有从普通 Nix source 部署的 Attic secret。
- 在真实主机使用 `stat` 检查 `/run/agenix` 文件，不使用 `cat` 输出内容。
- Pi 验证 Attic restart、上传和下载；GTR7 验证 watch-store；XPS13/Pi 验证只读 cache。
- 三台主机验证 Xray restart 后 unit 正常且代理连通。
- 使用只匹配文件名、配置键和已知占位符的扫描确认 tree 无明文；不得把 secret 本身作为
  命令行搜索参数。

## 回滚

- identity 迁移期保留新旧接收者重叠，主机验证后才删除旧接收者。
- 轮换后不能回滚到旧 token 或旧签名 secret；代码回滚必须继续引用新密文。
- Attic 服务失败时回滚到上一代代码和相同的新凭据，或临时禁用私有 substituter。
- Xray 权限失败时优先修正 unit credential 接入；临时权限回退必须单独记录并限时清除。

## 完成标准

- 旧 Attic 凭据已经失效，而不只是从当前分支删除。
- 当前 tree 和新 closure 不含明文 Attic 认证材料。
- 系统 activation 不再依赖 `/home/<user>/.ssh/id_ed25519`。
- 所有 runtime secret 权限、owner 和消费者匹配。
- 三台主机实际验证完成，并留下不含敏感值的验证记录。
