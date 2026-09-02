# Hobob overlay

`default.nix` 声明 `fool.hobob.overlay`。启用后，从 `inputs.hobob.packages.<system>.default` 创建 `pkgs.hobob`。

Pi host 启用该 overlay，`os/hobob` 系统服务依赖它提供的包名。
