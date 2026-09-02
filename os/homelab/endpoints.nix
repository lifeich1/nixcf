# 非敏感 homelab endpoint 默认值（唯一数据来源）。
#
# `os/homelab/default.nix` 以本文件作为 option 默认值；根 `flake.nix` 的
# `homelabEndpoints` output 向运维脚本（justfile）暴露同一份数据。
# 值均为公开配置（endpoint、cache 名、签名 public key）；token / netrc / 签名
# secret 绝不进入本文件，只由计划 01 的 runtime secret path 提供。
{
  pi = {
    hostName = "my-pi";
    lanAddress = "192.168.3.6";
  };
  proxy = {
    socksPort = 10809;
    migrationPort = 10819;
  };
  attic = {
    scheme = "http";
    port = 8080;
    cacheName = "my-pi_attic";
    publicKey = "my-pi_attic:ryUjSxUOb7D+cBc7Q7MfUXdd0isJWo8kteKETy9x2X0=";
  };
}
