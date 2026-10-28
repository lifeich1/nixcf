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
- `fool.dsh.profileName`：Nix 管理的 profile key，默认 `web`；materialized 后为
  `nix-web`。
- `fool.dsh.bundles`：该 profile 的 bundle 列表，当前为
  `[ pkgs.dsh.bundles.web-app ]`。
- `fool.dsh.mode`：默认 `managed`。managed 会在 activation 时生成
  `~/.dsh/profiles/nix-web`，并在每次运行 `dsh` 时恢复 `package.json` 与
  `cordis.patch.yml`；需要保留 Settings UI 或 `dsh plugin` 的运行时修改时改为
  `mutable`。
- `defaultProfile` 由模块自动设为 `nix-web`，不要在 profile 参数里直接写 `web`。

当前由 `home/desktop-common.nix` 在 GTR7 与 XPS13 启用，Pi 不启用。

## 使用

```sh
dsh --version
dsh web          # 首次启动会在 ~/.dsh 下初始化并打开 Web UI
dsh --help
```

API key 不写入 Nix：通过 dsh 的 Settings 或运行环境提供。模块不启用
`services.dsh`，也不安装桌面应用。

## 升级

dsh 版本跟随 `flake.lock` 中的 `deepseek-harness` 锁定 rev：

```sh
nix flake update deepseek-harness
just chk
```

nixpkgs pin 与社区 flake 验证过的 rev 保持一致，以复用
`https://deepseek-harness-nix.cachix.org` 的预构建缓存；该缓存配置位于
`os/nix/`。升级后需重新 activation，才能更新 `dsh` wrapper 与
`~/.dsh/profiles/nix-web`。
