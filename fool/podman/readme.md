# `fool/podman/`：Podman 用户级配置

启用后通过 `registries.conf.d` drop-in 向 Podman 注入 docker.io 仓库镜像
（`docker.xuanyuan.me`、`docker.1ms.run`、`docker.m.daocloud.io`）。

## Options

- `fool.podman.enable`：启用 Podman 用户配置。

## 为什么用 drop-in 而非主配置文件

Home Manager 的 `services.podman.settings.registries.registry` submodule 只支持
`location`/`insecure`/`blocked`，无法表达 `[[registry.mirror]]`。
`registries.conf.d/` 是 containers-registries.conf(5) 官方支持的扩展机制——
Podman 会把 drop-in 与 `$XDG_CONFIG_HOME/containers/registries.conf` 自动合并，
效果等效于在单一文件内声明全部配置。

## 边界

- 用户级 `registries.conf` 存在时 Podman 完全忽略系统级 `/etc/containers/registries.conf`，
  因此系统侧不再配置 registry mirrors。
- `fool.bililiverecorder` 中的 `services.podman.enable` 独立保留（值相同，幂等）。
- 当前仅在 gtr7（`home/pc`）启用。