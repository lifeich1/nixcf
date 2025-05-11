{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.bililiverecorder;
in
{
  options.fool.bililiverecorder = {
    enable = mkEnableOption "bililiverecorder (contained app)";
    # TODO flex pinned configs, pin config.json
  };

  config = mkIf cfg.enable {
    services.podman.enable = true;
    services.podman.containers.bililiverecorder = {
      image = "ghcr.io/bililiverecorder/bililiverecorder:2.17.0";
      # user = config.home.username;
      ports = [ "2356:2356" ];
      volumes = [ "${config.home.homeDirectory}/公共/bilirec:/rec" ];
      environment = {
        BREC_HTTP_OPEN_ACCESS = 1;
      };
    };
  };
}
