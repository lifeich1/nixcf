# amdgpu devcoredump

`default.nix` 通过 `fool.amdgpu-devcoredump.enable` 启用 GPU 硬挂现场自动收集：
udev 在 `SUBSYSTEM=="devcoredump"` 设备出现时拉起 `amdgpu-devcoredump@.service`，
把 `/sys/class/devcoredump/<devcd>/data` 拷贝到 `/var/lib/amdgpu-devcoredump/`。

- 触发方式：udev `add` 事件 + systemd template，不轮询、不依赖登录会话。
- 落盘内容：`<UTC 时间>-<devcd>.bin`（原始 dump）、`.meta`（内核版本、failing
  device）、`.dmesg`（采集时的内核日志）。
- 生命周期：devcoredump 由内核在创建时启动的定时器回收（默认 5 分钟，读取不续命）；
  本模块在事件后立即拷贝，拷贝成功再写 `data` 主动释放内核副本，避免短时间内二次
  挂起的新 dump 因槽位被占用而丢弃。
- 保留最近 10 份（`.bin` 与同名 `.meta`/`.dmesg`）；`/var/lib/amdgpu-devcoredump/`
  权限 `0700`，文件 `0600`（dump 可能包含显存内容）。
- udev 规则按 `devcoredump` 子系统匹配，不限于 amdgpu；本机实际触发者是 amdgpu，
  其他驱动若产生 devcoredump 也会被一并收集。
- 不要写 `/sys/class/devcoredump/disabled`：写 `1` 会删除所有现存 dump 并全局禁用，
  重启前不可恢复。
- 仅 GTR7 启用；XPS13 与 Pi 不启用。无网络监听、无防火墙规则。
- 需内核启用 `DEVCOREDUMP`（`linux-zen` 默认包含）；若整机彻底死锁或自动重启，
  udev/systemd 来不及执行，此类 dump 无法由本模块保留。
