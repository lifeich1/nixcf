# nixcf

管理三台机器的 NixOS flake：GTR7 桌面、XPS13 笔记本和 Raspberry Pi 4B homelab。系统模块使用 NixOS，用户配置使用 Home Manager，secret 使用 Agenix。

## Agent 快速导航

处理单台机器时，按以下顺序读取即可，通常不需要扫描整个仓库：

1. `flake.nix`：确认目标 `nixosConfiguration`、架构、模块列表和 Home profile。
2. `host/<hostname>/readme.md` 与 `configuration.nix`：确认硬件和系统服务开关。
3. `home/<profile>/readme.md` 与 `default.nix`：确认用户态功能开关。
4. 仅打开实际涉及的 `os/<module>/` 或 `fool/<module>/`；每个目录的 `readme.md` 描述入口、option 和依赖关系。

## 目录

- `host/`：每台机器的启动、硬件、用户与服务选择；共享 Nix/cache 设置在 `host/common.nix`。
- `home/`：GTR7、XPS13、Pi4B 对应的 Home Manager profile。
- `os/`：可复用的 NixOS 系统模块和服务。
- `fool/`：`fool.*` Home Manager 模块、用户工具和 overlays。
- `secrets/`：Agenix 声明、接收者与加密文件；不要输出或提交明文。
- `tools/`：运维辅助脚本；常用构建/部署命令集中在 `justfile`。
- `skill/`：项目本地维护约定，包括 Gitmoji commit message。

常用校验为 `just chk`（`nix flake check`）；部署命令为 `just pi`、`just xps` 和 `just gtr7`。运行 `just --list` 可按 build、deploy、dev、maintenance、info 分组查看其他操作。输入源与具体版本以 `flake.nix`、`flake.lock` 为准。
