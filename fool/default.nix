{
  config,
  pkgs,
  lib,
  username,
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
    ./cargo
    ./cfg-ssh
    ./com-lemonade
    ./cp-guard
    ./desktop
    ./fastfetch
    ./git
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

  config = mkMerge [
    {
      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      home.stateVersion = "23.11";

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      home.username = username;
      home.homeDirectory = "/home/${username}";

      programs.bash = {
        enable = true;
        enableCompletion = true;
      };

      fool.proxy.tcp_url = tcpUrl;
      fool.proxy.socks5_url = "socks5://${tcpUrl}";
    }
    {
      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        pinentry.package = mkDefault pkgs.pinentry-curses;
      };
    }
    (mkIf (!isNull config.fool.gpg.pinentry) {
      services.gpg-agent.pinentry.package = mkForce config.fool.gpg.pinentry;
    })
  ];
}
