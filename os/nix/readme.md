# `os/nix/`：Nix 守护进程配置

承接原 `host/common.nix` 的 Nix/cache 职责：GC 计划、auto-optimise、trusted-users、
substituter、trusted public key、netrc-file 与诊断开关（`trace-verbose`）。

`trace-verbose` 是临时诊断开关；标为 outdated 的 mirror 需独立连通性验证后删除。
修改 substituter / public key / netrc 时与 Pi 的 Attic 服务（`os/atticd`、
`fool/attic`）一起核对。
