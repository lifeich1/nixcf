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
            "${pubdir}/priv-films" = {
              id = "vzezm-upy2v";
              label = "priv-films";
            };
            "${pubdir}/priv-fast" = {
              id = "skc9k-3qpf5";
              label = "priv-fast";
            };
            "${pubdir}/ala-an70/default" = {
              id = "ggt3o-3c0ib";
              label = "ala-an70/default";
            };
            "${pubdir}/ala-an70/pics" = {
              id = "mjwxp-9joch";
              label = "ala-an70/pics";
            };
            "${pubdir}/ala-an70/camera" = {
              id = "ala-an70_pam5-照片";
              label = "ala-an70/pics";
            };
          };
          devices = {
            gtr7.id = "DYFRCJJ-7WNW3GF-XHTLMH3-2UBZ2TR-6KGAAAD-APLJK6F-GCVZQEJ-OWNC7QQ";
            matepad23.id = "VQKKXIY-JESAFSW-TE5MXQF-ND3H7IR-FKL357O-ZWNYPTP-O5OSKUC-Y4XK2AU";
            ala_an70.id = "6EBVCNG-JWOCLAQ-QWLUM73-4E3C2GY-FGDVWP3-P563Q3D-X62YMIN-5FILAA5";
            xps13_9360.id = "HJBCABV-UZBQV5P-V552XA2-B4D7DH5-T2WCHRS-I55ONAS-V6AB332-GKQ67Q4";
          };
        };
      };
  };
}
