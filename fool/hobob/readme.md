# Hobob 用户包

`default.nix` 通过 `fool.hobob.enable` 把 `pkgs.hobob` 加入用户环境。包本身由 `fool/overlays/hobob` 从 flake input 注入。

这里的用户级自启动服务目前被注释；Pi 上实际运行的是 `os/hobob` 的系统级服务。
