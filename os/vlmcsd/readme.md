# vlmcsd

`default.nix` 通过 `fool.vlmcsd.enable` 运行 KMS 服务并开放 TCP 1688。`invokeType` 可选：

- `cmd`：自定义 systemd service 直接执行 Podman，便于设置拉取代理。
- `nix`：使用 NixOS OCI container 声明。

Pi 当前选择 `nix`。镜像使用 `latest`，升级行为并非完全可复现，变更前应测试容器启动和端口监听。
