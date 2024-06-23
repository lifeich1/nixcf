{ config, lib, ... }:
with lib;
let
  cfg = config.fool.gitea;
in
{
  options.fool.gitea = {
    enable = mkEnableOption "gitea";
  };

  config = mkIf cfg.enable {
    services.gitea = {
      appName = "煎蛋摊";
      enable = true;
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = "my-pi";
        };
        proxy = {
          PROXY_ENABLED = true;
          PROXY_URL = "http://127.0.0.1:10819";
          PROXY_HOSTS = "*.github.com";
        };
        migrations = {
          ALLOW_LOCALNETWORKS = true;
          ALLOWED_DOMAINS = "";
        };
        service.DISABLE_REGISTRATION = true; # account created
      };
    };
  };
}
