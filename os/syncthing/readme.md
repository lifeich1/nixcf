# Syncthing

`default.nix` 通过 `fool.syncthing.enable` 启用系统级 Syncthing，数据根目录为用户的 `公共` 目录。

文件夹、设备 ID 和 receive-only 方向都在本文件中声明，但 `overrideFolders`/`overrideDevices` 为 false，允许运行态保留额外配置。修改拓扑时核对设备名、folder id 与同步方向，避免误覆盖数据。
