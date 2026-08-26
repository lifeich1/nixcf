# Bilibili Live Recorder

`default.nix` 提供 `fool.bililiverecorder.enable`，通过 Home Manager Podman 模块运行固定版本容器，对外映射 2356 端口，并把用户公共目录下的 `bilirec` 挂载到容器。

当前由 `home/pc` 启用。升级镜像时同时检查数据目录兼容性和 Web 访问配置。
