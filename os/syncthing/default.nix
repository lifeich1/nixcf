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
            "${pubdir}/ala-an70/default" = {
              id = "ggt3o-3c0ib";
              label = "ala-an70/default";
            };
          };
          devices = {
            gtr7.id = "DYFRCJJ-7WNW3GF-XHTLMH3-2UBZ2TR-6KGAAAD-APLJK6F-GCVZQEJ-OWNC7QQ";
            matepad23.id = "VQKKXIY-JESAFSW-TE5MXQF-ND3H7IR-FKL357O-ZWNYPTP-O5OSKUC-Y4XK2AU";
            ala_an70.id = "6EBVCNG-JWOCLAQ-QWLUM73-4E3C2GY-FGDVWP3-P563Q3D-X62YMIN-5FILAA5";
          };
        };
      };
  };
}
