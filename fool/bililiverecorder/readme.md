# Bilibili Live Recorder

`default.nix` 提供 `fool.bililiverecorder.enable`，通过 Home Manager Podman 模块运行 `source.json` 中固定版本的 GHCR 容器，对外映射 2356 端口，并把用户公共目录下的 `bilirec` 挂载到容器。

当前由 `home/pc` 启用。升级镜像时同时检查数据目录兼容性和 Web 访问配置。

运行 `just update-bililiverecorder` 可从 `ghcr.io/bililiverecorder/bililiverecorder` 的全部标签中选择最高的稳定 `X.Y.Z` 版本并原子更新 `source.json`。脚本忽略 `latest`、版本别名、预发布版和开发标签；查询、分页或数据校验失败时保留原文件并返回失败。
