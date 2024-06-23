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
    proxy = {
      enable = mkEnableOption "http(s) proxy";
      use-pi = mkEnableOption "using `my-pi` as proxy server";
      # TODO enabled directories
    };
  };

  config = {
    programs.git = {
      enable = mkDefault true;
      userName = mkDefault cfg.user;
      userEmail = mkDefault cfg.email;
      difftastic.enable = true;
      lfs.enable = true;
      extraConfig = mkIf cfg.proxy.enable (
        let
          url = config.proxy.socks5_url;
        in
        {
          https.proxy = url;
          http.proxy = url;
        }
      );
    };
  };
}
