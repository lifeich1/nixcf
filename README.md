# nixcf

管理三台机器的 NixOS flake：GTR7 桌面、XPS13 笔记本和 Raspberry Pi 4B homelab。系统模块使用 NixOS，用户配置使用 Home Manager，secret 使用 Agenix。

## Agent 快速导航

处理单台机器时，按以下顺序读取即可，通常不需要扫描整个仓库：

1. `flake.nix`：确认目标 `nixosConfiguration`、架构、模块列表和 Home profile。
2. `host/<hostname>/readme.md` 与 `configuration.nix`：确认硬件和系统服务开关。
3. `home/<profile>/readme.md` 与 `default.nix`：确认用户态功能开关。
4. 仅打开实际涉及的 `os/<module>/` 或 `fool/<module>/`；每个目录的 `readme.md` 描述入口、option 和依赖关系。

## 目录

- `hosts.nix`：三台主机的稳定元数据（hostname、username、architecture、Home profile、
  硬件模块、deploy target/tagPrefix）唯一来源。
- `host/`：每台机器的启动、硬件、用户与服务选择；机器差异之外的共享配置在 `os/`。
- `home/`：GTR7、XPS13、Pi4B 对应的 Home Manager profile。
- `os/`：可复用的 NixOS 系统模块和服务；`os/homelab/` 是 Pi 端点、proxy/Attic 端口的
  类型化唯一来源（`endpoints.nix` 数据文件与 `homelabEndpoints` output 同源）。
- `fool/`：`fool.*` Home Manager 模块与用户工具；外部 flake package 由模块 `package`
  option 在启用点显式注入，不使用全局 overlay。
- `secrets/`：Agenix 声明、接收者与加密文件；不要输出或提交明文。
- `tools/`：运维辅助脚本；常用构建/部署命令集中在 `justfile`。
- `.agents/skills/`：仓库专用 skill bundle 与项目维护约定，包括模块、secret、服务、flake、Nixvim、部署和 Gitmoji workflow。

常用校验为 `just chk`（`nix flake check`）；`just update` 会先更新固定的 BililiveRecorder 容器标签与 Reasonix CLI 包，再更新全部 flake inputs。单独更新可运行 `just update-bililiverecorder` 或 `just update-reasonix`。部署命令为 `just pi`、`just xps` 和 `just gtr7`，target/tag 从 `deployTargets` output 读取。运行 `just --list` 可按 build、deploy、dev、maintenance、info 分组查看其他操作。输入源与具体版本以 `flake.nix`、`flake.lock` 为准。
