# Gitea 服务：域名、migration proxy 从 os/homelab 派生。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.gitea;
  homelab = config.fool.homelab;
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
          DOMAIN = homelab.pi.hostName;
        };
        proxy = {
          PROXY_ENABLED = true;
          PROXY_URL = "http://127.0.0.1:${toString homelab.proxy.migrationPort}";
          PROXY_HOSTS = "*.github.com";
        };
        migrations = {
          ALLOW_LOCALNETWORKS = true;
          ALLOWED_DOMAINS = "";
        };
        service.DISABLE_REGISTRATION = true; # account created
        mailer.SENDMAIL_PATH = "/fix-merged-wait-deploy"; # FIXME remove this line in future
      };
    };
  };
}
