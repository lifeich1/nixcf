# kdocs

`default.nix` 声明 `fool.kdocs.enable`，启用后：

- 通过 `package.nix` 把官方 CDN 的固定版本 `kdocs-cli` 安装到用户环境（仅 `x86_64-linux`）。
- 把 kdocs skill 符号链接到 `~/.reasonix/skills/kdocs`：目录由 Nix store 接管，只读且始终
  等于 `source.json` 固定的版本。

GTR7 与 XPS13 通过 `home/desktop-common.nix` 启用，Pi4B 不启用。

## 版本与来源

`source.json` 固定 `version`、`cliHash`、`skillHash`，两者都来自
`https://wpsai.wpscdn.cn/skillhub/pro/v<version>/`：

- CLI 归档 `releases/kdocs-cli-<version>-linux-amd64.tar.gz`
- skill 归档 `kdocs.zip`

skill 内容随官网更新，不进入本仓库；仓库只保存版本号与两个 hash。

## 更新流程

`just update-kdocs`（已并入 `just update`）运行 `update.py`：

1. 查询最新版本：优先 `kdocs-cli call check_skill_update version=<当前> skill_name=kdocs`
   的 JSON（`data.latest`），回退 `kdocs-cli upgrade --check` 的版本行——已最新时实测为
   `Already on the latest version: <version>`，同时兼容 `Latest version: <version>`。
2. 校验 CLI 归档：从 `releases/checksums.txt` 取官方 sha256，再用
   `nix store prefetch-file --expected-hash` 核对实际内容。
3. 固定 skill zip 的 hash（官方 checksums 不覆盖 skill 归档）。
4. 原子写入 `source.json`；同版本 hash 漂移、版本回退或任何下载/校验失败都会保留原文件
   并返回失败。

改完 `source.json` 需要一次 Home Manager activation，才会把新版本链接到
`~/.reasonix/skills/kdocs` 并更新 PATH 中的 `kdocs-cli`。

## 为什么只读链接是安全的

官方 `SKILL.md` 的「保持最新版本」章节只在两种情况下改动自身或 CLI：

- CLI 版本低于 `SKILL.md` 的 `version` → 运行 `kdocs-cli upgrade -y`；
- `SKILL.md` 版本低于 `kdocs-cli` 版本 → 下载 zip 替换 skill 目录。

本模块用同一个 `source.json` 同时固定 CLI 与 skill，两者版本恒等，因此两条条件都不会成立，
只读链接不会阻断官方流程。反过来，`kdocs-cli` 也没有 skill 管理命令（`--help` 只列出文档
services、`call`、`upgrade`、`feedback`、`auth`），`call check_skill_update` 只返回最新版本与
zip 链接，不会替 agent 写目录。

边界：官方「保持最新版本」章节的故障恢复路径会在 skill 目录内运行 `bash scripts/setup.sh`
重装（脚本随 zip 分发在 `scripts/`），该操作需要写目录，在只读 store 下会失败。此时不要
绕过只读链接，应手工从 CDN 取新版并更新 `source.json`，再跑一次 activation。

## 备注

- 升级统一走 `just update-kdocs` + activation；不要依赖 `kdocs-cli upgrade`——Nix 管理的
  二进制位于只读 store，`upgrade` 面向的是 `~/.local/bin` 这类可写安装位置。
- 若手工安装的 `~/.local/bin/kdocs-cli` 仍优先于 Nix 版本，会造成 CLI 与 skill 版本错配并
  触发官方自更新流程；纳入 Nix 管理时应删除该副本。
- skill zip 内条目使用反斜杠路径（Windows 风格），`default.nix` 用 `unzip` 解压并在构建期
  断言 `$out/kdocs/SKILL.md` 存在，避免静默产出错误布局。
- 项目目录下的 `.reasonix/` 被 `.gitignore` 忽略；kdocs skill 只部署到全局
  `~/.reasonix/skills/`，不再放项目副本。
- 若 `~/.reasonix/skills/kdocs` 已是手工安装的普通目录，`home.file` 会因目标冲突导致
  activation 失败；启用前需先删除或迁移该目录（与 `fool/reasonix/skills.nix` 的处理一致）。
- skill zip 没有官方 checksum 覆盖（`releases/checksums.txt` 只含 CLI 归档），`skillHash`
  由 `nix store prefetch-file` 首次计算得到，属于对 CDN 内容的信任起点；CLI 归档则与官方
  sha256 交叉校验。
