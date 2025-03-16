{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.hobob;
in
{
  options.fool.hobob = {
    sys-service = mkEnableOption "hobob sys service";
  };

  config = mkIf cfg.sys-service {
    systemd.services."programs-hobob" = {
      description = "Autostart hobob";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.hobob}/bin/hobob";
      serviceConfig = {
        WorkingDirectory = "/opt/hobob";
      };
    };
  };
}
