# Xray 用户态安装器

`default.nix` 的 `fool.xray.installer` 生成 `setup-xray` 脚本，用于非 NixOS 环境手工安装 systemd service。

NixOS 主机不要启用该 installer：系统服务由 `services.xray` 管理，配置文件由 `secrets/default.nix` 解密到固定路径。
