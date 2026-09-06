# Syncthing

`os/syncthing/default.nix`（通用 wrapper）通过 `fool.syncthing.enable` 启用系统级
Syncthing，数据根目录为用户的 `公共` 目录；`fool.syncthing.openFirewall` passthrough 到
上游 `services.syncthing.openDefaultPorts`（TCP/UDP 22000 + UDP 21027）。

`os/syncthing/topology.nix`（个人拓扑 data module）声明 folders、device ID 与
receive-only 方向，由 GTR7/XPS13 host 在 `imports` 中显式引入。`overrideFolders` /
`overrideDevices` 为 false，允许运行态保留额外配置（refactor-plan-04 阶段 7：拆分不改
folder id/path/type、同步方向与设备）。修改拓扑时核对设备名、folder id 与同步方向，
避免误覆盖数据。
