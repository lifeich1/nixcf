{
  config,
  lib,
  osConfig,
  ...
}:
with lib;
let
  hmCfg = config.fool.proxy;
  # SOCKS host/port 的唯一来源是系统侧 os/homelab；HM 只保留 use-pi profile 选择，
  # 不再接收可覆盖的 host/URL option。
  hl = osConfig.fool.homelab;
  proxyHost = if hmCfg.use-pi then hl.pi.hostName else "127.0.0.1";
  tcpUrl = "${proxyHost}:${toString hl.proxy.socksPort}";
in
{
  imports = [
    ./alacritty
    ./attic
    ./bililiverecorder
    ./cfg-ssh
    ./com-lemonade
    ./cp-guard
    ./desktop
    ./fastfetch
    ./git
    ./kdocs
    ./misc
    ./nvim
    ./reasonix
    ./wezterm
    ./zsh
  ];

  options.fool = {
    proxy = {
      use-pi = mkEnableOption "use `my-pi` as proxy server";
      tcp_url = mkOption {
        internal = true;
        type = types.str;
        description = "派生 host:port，供 SSH ProxyCommand 等使用";
      };
      socks5_url = mkOption {
        internal = true;
        type = types.str;
        description = "派生 socks5:// URL，供 git 等使用";
      };
    };

    gpg = {
      pinentry = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "costom pinentryPackage or use pinentry-curses default.";
      };
    };
  };

  # username/homeDirectory/stateVersion、Home Manager、Bash 与 GPG 基线位于
  # `home/common.nix`（由三个 profile 显式导入），这里只保留模块聚合、
  # 共享 option 定义与跨模块派生的 proxy 地址。
  config = mkMerge [
    {
      fool.proxy.tcp_url = tcpUrl;
      fool.proxy.socks5_url = "socks5://${tcpUrl}";
    }
    (mkIf (!isNull config.fool.gpg.pinentry) {
      services.gpg-agent.pinentry.package = mkForce config.fool.gpg.pinentry;
    })
  ];
}
