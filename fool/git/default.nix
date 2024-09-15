{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.git;
in
{
  options.fool.git = {
    user = mkOption {
      type = types.str;
      default = "lifeich1";
      description = "git userName";
    };
    email = mkOption {
      type = types.str;
      default = "lifeich0@gmail.com";
      description = "git userEmail";
    };
    github-proxy = mkEnableOption "enable http(s) proxy for github cloned path.";
  };

  config = {
    programs.git = {
      enable = mkDefault true;
      userName = mkDefault cfg.user;
      userEmail = mkDefault cfg.email;
      difftastic.enable = true;
      lfs.enable = true;
      extraConfig = mkIf cfg.github-proxy {
        includeIf."gitdir:Code/z/github.com/**".path =
          let
            suffix = config.xdg.configFile."fool_git_http_proxy.inc".target;
          in
          "${config.home.homeDirectory}/${suffix}";
      };
    };

    xdg.configFile."fool_git_http_proxy.inc".text = ''
      [http]
      proxy = ${config.fool.proxy.socks5_url};

      [https]
      proxy = ${config.fool.proxy.socks5_url};
    '';
  };
}
