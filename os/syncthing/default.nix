{
  config,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.fool.syncthing;
in
{
  options.fool.syncthing = {
    enable = mkEnableOption "service syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing =
      let
        datadir = "/home/${username}";
        pubdir = "${datadir}/公共";
      in
      {
        enable = true;
        user = username;
        dataDir = datadir;
        overrideFolders = false;
        overrideDevices = false;
        settings = {
          folders = {
            "${pubdir}/default" = {
              id = "default";
              label = "default";
            };
          };
        };
      };
  };
}
