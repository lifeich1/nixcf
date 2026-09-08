# Bilibili Live Recorder

`default.nix` 提供 `fool.bililiverecorder.enable`，通过 Home Manager Podman 模块运行
`source.json` 中固定版本的 GHCR 容器。

options：

- `fool.bililiverecorder.image`：镜像引用，默认
  `ghcr.io/bililiverecorder/bililiverecorder:<source.json 版本>`（可用 digest 覆盖）。
- `fool.bililiverecorder.dataDir`：录制数据目录，默认 `~/公共/bilirec`（挂载到容器
  `/rec`）。
- `fool.bililiverecorder.hostPort`：宿主端口，默认 2356（容器内固定 2356，映射字符串由
  module 生成）。
- `fool.bililiverecorder.openAccess`：`BREC_HTTP_OPEN_ACCESS`，默认 true。

当前由 `home/pc`（GTR7）启用。**2356 仅本机访问**（阶段 3 收紧决策：未在 gtr7 firewall
放行 LAN，dec-253371726938ba51）；若需 LAN 访问须另行显式放行。升级镜像时同时检查数据
目录兼容性和 Web 访问配置。

运行 `just update-bililiverecorder` 可从 `ghcr.io/bililiverecorder/bililiverecorder` 的
全部标签中选择最高的稳定 `X.Y.Z` 版本并原子更新 `source.json`。脚本忽略 `latest`、版本
别名、预发布版和开发标签；查询、分页或数据校验失败时保留原文件并返回失败。
