{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.bililiverecorder;
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
{
  options.fool.bililiverecorder = {
    enable = mkEnableOption "bililiverecorder (contained app)";
  };

  config = mkIf cfg.enable {
    services.podman.enable = true;
    services.podman.containers.bililiverecorder = {
      image = "ghcr.io/bililiverecorder/bililiverecorder:${source.version}";
      # user = config.home.username;
      ports = [ "2356:2356" ];
      volumes = [ "${config.home.homeDirectory}/公共/bilirec:/rec" ];
      environment = {
        BREC_HTTP_OPEN_ACCESS = 1;
      };
    };
  };
}
