{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.git;
in
{
  options.fool.git = {
    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "git userName";
    };
    email = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "git userEmail";
    };
    github-proxy = mkEnableOption "enable http(s) proxy for github cloned path.";
  };

  config = {
    programs.git = {
      enable = mkDefault true;
      lfs.enable = true;
      settings.user = mkIf (cfg.user != null && cfg.email != null) {
        email = mkDefault cfg.email;
        name = mkDefault cfg.user;
      };
      signing.format = "openpgp";
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