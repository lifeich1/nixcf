#!/usr/bin/env bash
# 无 just 环境下的 nix-daemon 临时代理 bootstrap。
#
# 等价于根 justfile 的 `proxy` / `no-proxy` recipe：
#   tools/proxy.sh [host]        # 设置 nix-daemon 走 socks5h://host:port
#   tools/proxy.sh --no-proxy    # 移除临时 drop-in，恢复直连
#
# SOCKS 端口从 flake output `.#homelabEndpoints.proxy.socksPort` 读取
# （os/homelab/endpoints.nix 为唯一来源，本文件不复制端口字符串）。
# HOST_NO_PROXY 常量需与 justfile 保持一致，改动时两边同步。
set -euo pipefail

# 与 justfile 的 HOST_NO_PROXY 保持一致。
HOST_NO_PROXY="127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn,gitee.com"
DROP_IN="/run/systemd/system/nix-daemon.service.d/override.conf"

# 定位 flake 根，允许从任意 cwd 调用本脚本。
cd "$(git rev-parse --show-toplevel)"

daemon_restart() {
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon
}

usage() {
  cat >&2 <<'EOF'
用法：
  tools/proxy.sh [host]        # 设置 nix-daemon 临时代理（默认 host=127.0.0.1）
  tools/proxy.sh --no-proxy    # 移除临时代理 drop-in 并重启 nix-daemon
EOF
  exit 1
}

case "${1:-}" in
  --help | -h)
    usage
    ;;
  --no-proxy)
    sudo rm -f "$DROP_IN"
    daemon_restart
    echo "removed $DROP_IN; nix-daemon back to direct connection"
    ;;
  -*)
    echo "error: unknown option: $1" >&2
    usage
    ;;
  *)
    host="${1:-127.0.0.1}"
    # socksPort 在 endpoints.nix 中为整数，--raw 只接受字符串，
    # 故用 `tr -d '"'` 去引号（与 tools/eval-assertions.sh 一致）。
    port="$(nix eval .#homelabEndpoints.proxy.socksPort | tr -d '"')"
    tmpfile="$(mktemp /tmp/nix-daemon-proxy.XXXXXX)"
    trap 'rm -f "$tmpfile"' EXIT
    {
      echo "[Service]"
      echo "Environment=\"https_proxy=socks5h://${host}:${port}\""
      echo "Environment=\"no_proxy=${HOST_NO_PROXY}\""
    } > "$tmpfile"
    sudo install -Dm0644 "$tmpfile" "$DROP_IN"
    daemon_restart
    echo "nix-daemon now uses socks5h://${host}:${port}"
    ;;
esac
