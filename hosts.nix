# 三台主机的稳定元数据（host registry）。
#
# 本文件是 hostname / username / architecture / Home profile / 硬件与前置模块 /
# deploy target 的唯一权威来源。服务 enable、文件系统、stateVersion 与 secret
# 不在此声明，仍由各 host 的 `configuration.nix` 显式选择。
#
# 字段说明：
# - `system` / `username` / `homeModule`：直接供 `flake.nix` 组装配置。
# - `device`：host 短标识（hostname 去掉 `nixos-` 前缀）。`secrets/` 仍以它选择
#   age 文件与分支，值保持不变。
# - `modules`：相对 Home Manager 模块的硬件/前置模块，合并自旧
#   `extraModules.beforeHome/afterHome`（合并后相对注册顺序改变，求值差异由
#   toplevel drvPath 与基线对比验证）。
# - `deploy`：供 `deployTargets` output 暴露给运维脚本，不包含 secret。
{
  nixos-hardware,
}:
{
  nixos-xps13 = {
    system = "x86_64-linux";
    username = "fool";
    device = "xps13";
    homeModule = ./home/lightpad;
    modules = [
      nixos-hardware.nixosModules.dell-xps-13-9360
    ];
    deploy = {
      target = "root@192.168.3.21";
      tagPrefix = "xps";
    };
  };

  nixos-gtr7 = {
    system = "x86_64-linux";
    username = "fool";
    device = "gtr7";
    homeModule = ./home/pc;
    modules = with nixos-hardware.nixosModules; [
      common-pc
      # AMD Ryzen™ 7 7840HS (zen4)
      common-cpu-amd
      common-cpu-amd-pstate
      # XXX zenpower abandoned zen4
      common-cpu-amd-raphael-igpu
      # nvme m2
      common-pc-ssd
    ];
    deploy = {
      target = "root@10.42.0.2"; # direct connection
      tagPrefix = "gtr7";
    };
  };

  nixos-pi4b = {
    system = "aarch64-linux";
    username = "pi";
    device = "pi4b";
    homeModule = ./home/micro-srv;
    modules = [
      nixos-hardware.nixosModules.raspberry-pi-4
      ./os/atticd
    ];
    deploy = {
      target = "root@my-pi";
      tagPrefix = "pi";
    };
  };
}
