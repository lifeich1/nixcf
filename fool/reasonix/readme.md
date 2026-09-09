# Reasonix CLI

`default.nix` 声明 `fool.reasonix.enable`，启用后将预编译的 Reasonix CLI 安装到用户环境。当前包只支持 `x86_64-linux`，GTR7 与 XPS13 通过 `home/desktop-common.nix` 启用，Pi4B 不启用。

`package.nix` 从 GitHub Releases 下载固定版本的 `reasonix-linux-amd64.tar.gz`，只安装其中的静态 `reasonix` 可执行文件。版本和 SHA-256 保存在 `source.json`，不使用会漂移的 latest URL。

运行 `just update-reasonix` 可查询最新稳定 `vX.Y.Z` CLI release，核对 GitHub asset digest 与 Nix 预取 hash 后原子更新 `source.json`。脚本忽略 draft、preview、Desktop 和 Studio release；任何查询、资产或校验失败都会保留原文件并返回失败。

## config.toml 的 Nix 化

`config.nix` 把 `~/.reasonix/config.toml` 的核心项纳入声明式配置：

- `fool.reasonix.settings`：`configVersion`、`defaultModel`、`language`、`credentialsStore`、`ui`、`agent`、`permissions`、`sandbox` 以及 `providers`（渲染为 `[[providers]]` 数组表）。默认值对齐仓库当前记录的实际取值，未改动的项不会改变行为。
- `fool.reasonix.extraConfig`：原文透传到文件末尾，用于 `[bot]`、`[desktop]`、`[[plugins]]` 等未 Nix 化的表。TOML 要求顶层标量键先于所有表，因此这里只能追加表/数组表；顶层键请改用 `settings`。
- `fool.reasonix.config.enable`：默认 `true`，随 `fool.reasonix.enable` 一起生效。
- `fool.reasonix.config.force`：默认 `false`，打开后每次 activation 都用 Nix 生成的配置覆盖 `~/.reasonix/config.toml`（覆盖前备份为 `config.toml.bak`）。

写入语义是**种子式**：仅当 `~/.reasonix/config.toml` 不存在（或 `force = true`）时，用 `install -m 0600` 写入一份 Nix 生成的配置。CLI 后续保存的改动（切换模型、`/config set` 等）在 `just gtr7` / `just xps` 之后仍然保留；想回到 Nix 定义的状态就把 `force` 打开一次。

API key 不在这个文件里：provider 只声明 `api_key_env`（`DEEPSEEK_API_KEY` / `SCNET_API_KEY`），密钥仍由环境提供。

查看生成的 store 路径：

```
nix eval --raw .#nixosConfigurations.nixos-gtr7.config.home-manager.users.fool.fool.reasonix.configFile
```

## 全局 skill 的声明式部署

`skills.nix` 把仓库内的全局 skill 链接到 Reasonix 的全局 skill 目录：

- `fool.reasonix.skills.enable`：默认 `true`，随 `fool.reasonix.enable` 一起生效。
- 源目录 `skills/labyrinth-dimension/`（`SKILL.md` + `references/egress-reference.md`）由
  `home.file` 链接到 `~/.reasonix/skills/labyrinth-dimension`，内容来自 Nix store，随
  activation 更新，不需要手工复制。
- `~/.reasonix/skills/` 中的 skill 对任意项目生效；仓库 `.agents/skills/` 下的项目 skill
  保持独立，不受本模块影响。
- 模块只声明自己拥有的子目录，`~/.reasonix/skills/` 下其他未纳管内容（例如手工放置的
  `commit-message`）不会被覆盖或删除。
- 目标位置若已存在同名普通文件或目录，Home Manager 会报冲突，需先手工清理再切换。

该 skill 内容与 nixcf 解耦：代理端点运行时探测，仅把本仓库的 `os/homelab` 派生值作为
可选交叉核对来源。生效需要一次 Home Manager activation（`just gtr7` / `just xps`），
本模块不修改 `config.toml`。
