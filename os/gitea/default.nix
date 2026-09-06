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
    # Gitea HTTP 端口 3000（NixOS services.gitea 默认），规则由本 module 拥有；
    # 收紧宽范围（refactor-plan-04 阶段 3）前须由 host 显式开启。
    openFirewall = mkEnableOption "open gitea port tcp:3000 (LAN access)";
    domain = mkOption {
      type = types.str;
      default = homelab.pi.hostName;
      description = "Gitea server.DOMAIN（默认 my-pi，来自 fool.homelab.pi.hostName）";
    };
    migrationProxy = mkEnableOption "GitHub migration 经本机 HTTP migration proxy";
    allowRegistration = mkOption {
      type = types.bool;
      default = false;
      description = "允许公开注册（默认关闭，账户已在 Pi 创建）";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.gitea = {
        appName = "煎蛋摊";
        enable = true;
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = cfg.domain;
          };
          migrations = {
            ALLOW_LOCALNETWORKS = true;
            ALLOWED_DOMAINS = "";
          };
          service.DISABLE_REGISTRATION = !cfg.allowRegistration;
          # 不设置 mailer.SENDMAIL_PATH：上游 services.gitea module 自行声明该
          # option 并按 mailer.ENABLED/PROTOCOL 派生默认值（refactor-plan-04 阶段 5
          # 求值确认，旧 /fix-merged-wait-deploy 占位已删除）。
        }
        // (lib.optionalAttrs cfg.migrationProxy {
          proxy = {
            PROXY_ENABLED = true;
            PROXY_URL = "http://127.0.0.1:${toString homelab.proxy.migrationPort}";
            PROXY_HOSTS = "*.github.com";
          };
        });
      };
    })
    (mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = [ 3000 ];
    })
  ];
}
