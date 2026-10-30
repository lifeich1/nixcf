# amdgpu devcoredump 自动收集。
#
# GPU 硬挂（ring timeout / MES reset 失败）时，内核通过 devcoredump 框架暴露
# /sys/class/devcoredump/devcdN/data；该缓冲有固定寿命（默认 5 分钟，读取不续命），
# 等想起来再手动备份必然错过。本模块在 udev add 事件上启动 oneshot，把 data 落到
# /var/lib/amdgpu-devcoredump/，供上游报障。
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.amdgpu-devcoredump;
  stateDir = "/var/lib/amdgpu-devcoredump";

  collect = pkgs.writeShellScript "amdgpu-devcoredump-collect" ''
    set -euo pipefail

    dev="$1"
    src="/sys/class/devcoredump/$dev/data"
    [ -r "$src" ] || exit 0

    ts="$(date -u +%Y%m%dT%H%M%SZ)"
    base="${stateDir}/$ts-$dev"
    tmp="$base.bin.part"
    trap 'rm -f "$tmp"' EXIT

    # sysfs bin attr 的 size=0，必须读到 EOF；cp 可能按 st_size=0 拷贝 0 字节。
    cat "$src" > "$tmp"
    [ -s "$tmp" ] || {
      echo "empty devcoredump: $dev" >&2
      exit 1
    }
    sync
    mv "$tmp" "$base.bin"
    trap - EXIT

    {
      echo "dev=$dev"
      echo "collected=$ts"
      echo "kernel=$(uname -r)"
      echo "failing_device=$(readlink -f "/sys/class/devcoredump/$dev/failing_device" || true)"
    } > "$base.meta"

    dmesg > "$base.dmesg" 2>/dev/null || true

    # 拷贝成功后主动销毁内核副本：释放内存，并让短时间内再次挂起能生成新 dump
    # （devcoredump 对同一 failing device 只保留一份未删除的 dump）。
    printf 1 > "$src" || true

    # 只保留最近 10 份（连同同名 .meta/.dmesg）。
    ls -1t ${stateDir}/*.bin 2>/dev/null | tail -n +11 | while IFS= read -r f; do
      rm -f "$f" "''${f%.bin}.meta" "''${f%.bin}.dmesg"
    done || true
  '';
in
{
  options.fool.amdgpu-devcoredump = {
    enable = mkEnableOption "amdgpu devcoredump collector";
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="devcoredump", TAG+="systemd", ENV{SYSTEMD_WANTS}+="amdgpu-devcoredump@%k.service"
    '';

    systemd.services."amdgpu-devcoredump@" = {
      description = "Collect amdgpu devcoredump %i";
      path = [
        pkgs.coreutils
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        UMask = "0077";
        StateDirectory = "amdgpu-devcoredump";
        StateDirectoryMode = "0700";
        ExecStart = "${collect} %i";
      };
    };
  };
}
