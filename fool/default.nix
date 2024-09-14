{
  config,
  pkgs,
  lib,
  username,
  device,
  ...
}:
with lib;
{
  imports = [
    ./alacritty
    ./cargo
    ./cfg-ssh
    ./fastfetch
    ./git
    ./hobob
    ./nvim
    ./xray
    ./zsh
  ];

  options.fool = {
    proxy = {
      use-pi = mkEnableOption "use `my-pi` as proxy server";
      port = mkOption {
        type = types.int;
        default = 10809;
        description = "socks5 port of proxy server";
      };
      host = mkOption {
        internal = true;
        default = "127.0.0.1";
        type = types.str;
      };
      tcp_url = mkOption {
        internal = true;
        type = types.str;
      };
      socks5_url = mkOption {
        internal = true;
        type = types.str;
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

      fool.proxy.tcp_url =
        let
          inherit (config.fool.proxy) host;
          port = toString config.fool.proxy.port;
        in
        "${host}:${port}";
      fool.proxy.socks5_url = "socks5://${config.fool.proxy.tcp_url}";
    }
    (mkIf config.fool.proxy.use-pi { fool.proxy.host = "my-pi"; })
    {
      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        pinentryPackage = mkDefault pkgs.pinentry-curses;
      };
    }
    (mkIf (!isNull config.fool.gpg.pinentry) {
      services.gpg-agent.pinentryPackage = mkForce config.fool.gpg.pinentry;
    })
  ];
}
