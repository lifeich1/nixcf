# DeepSeek Harness（dsh）

`fool.dsh` 通过社区 flake `Moraxyc/deepseek-harness.nix` 安装 DeepSeek Harness CLI，
并使用其 Home Manager 模块的 `programs.dsh.profiles` 声明插件组合。

## Overlay 例外

本仓库通常不使用全局 overlay。`deepseek-harness` 的 `profiles` 需要
`pkgs.dsh.bundles.*`，因此 `flake.nix` 仅在 `x86_64-linux` host 注入
`inputs.deepseek-harness.overlays.default`；Pi（`aarch64-linux`）不应用该 overlay，
也不启用本模块。

## 选项

- `fool.dsh.enable`：启用 dsh CLI 与 profile 管理。
- `fool.dsh.package`：dsh CLI 包，由启用点传入 `pkgs.dsh.dsh`。
- `fool.dsh.profiles`：Nix 管理的 profile 集合，key 为 profile 名，materialized 后为
  `nix-<name>`；每项支持 `bundles` 与 `mode`。当前声明：
  - `web`：`[ pkgs.dsh.bundles.web-app ]`
  - `tui`：`[ pkgs.dsh.bundles.tui ]`
- `fool.dsh.patch`：Home 级 Cordis patch 层（上游 `programs.dsh.patch`），写入
  `$DSH_HOME/cordis.patch.yml`，在 profile patch 之后应用，因此优先级更高。当前用它
  声明 JuFlow provider；该层由 Nix 管理，Models 页面不能改写其中的 `llm-pi-ai` 行。
- `fool.dsh.defaultProfile`：默认 profile 的 key（不加 `nix-` 前缀），当前为 `tui`，
  即 materialized 后的 `nix-tui`；必须是 `fool.dsh.profiles` 中已声明的 key。
- `bundles` 的 `mode` 默认 `managed`。managed 会在 activation 时生成
  `~/.dsh/profiles/nix-<name>`，并在每次运行 `dsh` 时恢复 `package.json` 与
  `cordis.patch.yml`；需要保留 Settings UI 或 `dsh plugin` 的运行时修改时改为
  `mutable`。
- `defaultProfile` 由模块自动加上 `nix-` 前缀，不要手写 `nix-tui`。
- `tui` profile 的 bundle 带 `passthru.requiresTty`，构建期 `dshBundleCheckHook`
  需要在伪终端中执行冒烟检查；模块会把这类 profile 名回传给
  `dshBundleCheckTtyProfiles`，避免上游 runtime 包清空 `profiles` 后误走非 TTY 路径。

当前由 `home/desktop-common.nix` 在 GTR7 与 XPS13 启用，Pi 不启用。

## 使用

```sh
dsh --version
dsh              # 默认使用 nix-tui profile
dsh --profile nix-web   # 显式使用 Web UI profile
dsh --help
```

API key 不写入 Nix：provider 只声明 `apiKeyEnv = "JUFLOW_API_KEY"`，值由 dsh 凭据
存储（`~/.dsh/.credentials.yaml` 的 `refs`）或环境提供。模块不启用 `services.dsh`，
也不安装桌面应用。

## JuFlow provider

`home/desktop-common.nix` 通过 `fool.dsh.patch` 声明 `llm-pi-ai` 的 `juflow` 路由：

- route key：`juflow`
- 协议：`openai-completions`（JuFlow 是 New API 中转，公开 `/v1/chat/completions`）
- 端点：`https://juflowai.com/v1`
- 凭据引用：`JUFLOW_API_KEY`；密钥值不进入 Nix
- 模型：`DeepSeek-V4-Pro-0813`、`qwen3.8-max`、`glm-5.3`、`glm-5.3-flash`、
  `DeepSeek-V4.1-flash`、`DeepSeek-V4.1-Flash-1017`、`kimi-k3.1-pro`、`kimi-k3`
  （视频模型 `doubao-seedance-2-5-260628`、`wan3.0-video` 不纳入）

模型列表是 JuFlow 公开 `/api/pricing` 的快照；JuFlow 增删模型时需要同步修改
`home/desktop-common.nix` 并重新 activation。因为 home patch 优先于 profile patch，
Models 页面不能改写这个 provider 的配置，运行时修改会被 Nix 管理值覆盖或拒绝。

## 升级

dsh 版本跟随 `flake.lock` 中的 `deepseek-harness` 锁定 rev：

```sh
nix flake update deepseek-harness
just chk
```

nixpkgs pin 与社区 flake 验证过的 rev 保持一致，以复用
`https://deepseek-harness-nix.cachix.org` 的预构建缓存；该缓存配置位于
`os/nix/`。升级后需重新 activation，才能更新 `dsh` wrapper 与
`~/.dsh/profiles/nix-{tui,web}`。
