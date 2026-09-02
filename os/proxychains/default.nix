# Proxychains：系统级 SOCKS5 代理客户端。
#
# 始终启用 `programs.proxychains`，定义名为 `lray` 的 SOCKS5 代理。host/port 从
# `os/homelab` 的类型化配置派生：`use-pi` 时指向 Pi 的 LAN address + socksPort，
# 否则指向 `127.0.0.1`。Home Manager 的代理消费见 `fool/`。
{ config, lib, ... }:
with lib;
let
  homelab = config.fool.homelab;
in
{
  config = {
    programs.proxychains = {
      enable = true;
      proxies = {
        lray = {
          enable = true;
          type = "socks5";
          host = if homelab.proxy.use-pi then homelab.pi.lanAddress else "127.0.0.1";
          port = homelab.proxy.socksPort;
        };
      };
    };
  };
}
