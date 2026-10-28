# `os/nix/`：Nix 守护进程配置

承接原 `host/common.nix` 的 Nix/cache 职责：GC 计划、auto-optimise、trusted-users、
substituter、trusted public key、netrc-file 与诊断开关（`trace-verbose`）。

`trace-verbose` 默认关闭；需要排查构建/求值问题时在对应 host 临时设
`nix.settings.trace-verbose = true`。标为 outdated 的 `mirror.sjtu.edu.cn` substituter
已移除；重新引入任何 mirror 前先做独立连通性验证。
修改 substituter / public key / netrc 时与 Pi 的 Attic 服务（`os/atticd`、
`fool/attic`）一起核对。

## DeepSeek Harness Cachix

`substituters` 末尾追加 `https://deepseek-harness-nix.cachix.org`，
`trusted-public-keys` 追加对应公钥，用于 `Moraxyc/deepseek-harness.nix` 的
`dsh` 预构建包。该缓存只读、只包含 dsh 相关路径，不参与 Pi 的 Attic 写入路径，
因此与 `os/atticd` / `fool/attic` 不冲突；连通性可用
`nix store ping --store https://deepseek-harness-nix.cachix.org` 验证。
