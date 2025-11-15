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
      lfs.enable = true;
      settings = {
        user = {
          email = mkDefault cfg.email;
          name = mkDefault cfg.user;
        };
      };
      includes = [
        (mkIf cfg.github-proxy {
          condition = "gitdir:Code/z/github.com/**";
          contents = {
            http.proxy = "${config.fool.proxy.socks5_url}";
            https.proxy = "${config.fool.proxy.socks5_url}";
          };
        })
      ];
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };
  };
}
