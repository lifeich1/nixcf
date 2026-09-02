# homelab 端点与 Pi 解析/代理语义的类型化配置。
#
# 非敏感 endpoint（DNS name、LAN address、端口、cache 名、public key）的唯一来源；
# token / netrc / 签名 secret 只由计划 01 的 runtime secret path（/run/agenix）提供。
# 字段默认值为当前三台主机实际使用的值；定义位置可以移动，URL/端口值不允许漂移。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.homelab;
in
{
  options.fool.homelab = {
    pi = {
      hostName = mkOption {
        type = types.str;
        default = "my-pi";
        description = "Pi 的 DNS name（LAN 内由 networking.hosts 解析）";
      };
      lanAddress = mkOption {
        type = types.str;
        default = "192.168.3.6";
        description = "Pi 的 LAN 地址";
      };
      resolvable = mkOption {
        type = types.bool;
        default = true;
        description = "把 lanAddress→hostName 写入 networking.hosts；Pi 本机应设为 false 并自行处理 loopback 解析";
      };
    };
    proxy = {
      use-pi = mkEnableOption "system proxychains 使用 Pi 的 SOCKS proxy（false 时指向 127.0.0.1）";
      socksPort = mkOption {
        type = types.port;
        default = 10809;
        description = "SOCKS5 proxy 端口";
      };
      migrationPort = mkOption {
        type = types.port;
        default = 10819;
        description = "Gitea migration 用 HTTP proxy 端口，独立于 SOCKS 端口";
      };
    };
    attic = {
      scheme = mkOption {
        type = types.str;
        default = "http";
        description = "Attic binary cache 协议";
      };
      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Attic 服务端口";
      };
      cacheName = mkOption {
        type = types.str;
        default = "my-pi_attic";
        description = "Attic cache 名称";
      };
      publicKey = mkOption {
        type = types.str;
        default = "my-pi_attic:ryUjSxUOb7D+cBc7Q7MfUXdd0isJWo8kteKETy9x2X0=";
        description = "Attic 签名 public key（非 secret）";
      };
      endpoint = mkOption {
        type = types.str;
        internal = true;
        description = "派生的 Attic endpoint URL（scheme://hostName:port）";
      };
    };
  };

  config = mkMerge [
    {
      fool.homelab.attic.endpoint =
        "${cfg.attic.scheme}://${cfg.pi.hostName}:${toString cfg.attic.port}";
    }
    (mkIf cfg.pi.resolvable {
      networking.hosts."${cfg.pi.lanAddress}" = [ cfg.pi.hostName ];
    })
    {
      assertions = [
        {
          assertion = !cfg.proxy.use-pi || cfg.pi.resolvable;
          message = "fool.homelab.proxy.use-pi = true 要求 Pi 可解析（pi.resolvable = true）";
        }
      ];
    }
  ];
}
