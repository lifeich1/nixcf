{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.bililiverecorder;
in
{
  config = mkIf cfg.olived {
    services.podman.enable = true;
    services.podman.containers.olived = {
      image = "docker.io/olivedapp/olived-web:latest";
      ports = [ "9843:9843" ];
      environment = {
        PUID = 1000;
        PGID = 1000;
        TZ = Asia/Shanghai;
        PORT = 9843;
      };
      volumes = [
        "${config.home.homeDirectory}/公共/olived:/olivedapp/olivedpro_downloads"
      ];
    };
  };
}
