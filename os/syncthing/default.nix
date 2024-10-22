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
        dataDir = pubdir;
        configDir = datadir + "/.config/syncthing";
        overrideFolders = false;
        overrideDevices = false;
        settings = {
          folders = {
            "${pubdir}/default" = {
              id = "default";
              label = "default";
              devices = [
                "gtr7"
                "xps13_9360"
                "matepad23"
              ];
            };
            "${pubdir}/drawings" = {
              id = "ptwgc-xwsas";
              label = "drawings";
              devices = [
                "gtr7"
                "xps13_9360"
                "matepad23"
              ];
            };
            "${pubdir}/priv-films" = {
              id = "vzezm-upy2v";
              label = "priv-films";
              devices = [
                "gtr7"
                "xps13_9360"
                "matepad23"
                "ala_an70"
              ];
            };
            "${pubdir}/priv-fast" = {
              id = "skc9k-3qpf5";
              label = "priv-fast";
              devices = [
                "gtr7"
                "xps13_9360"
                "matepad23"
                "ala_an70"
              ];
            };
            "${pubdir}/ala-an70/default" = {
              id = "ggt3o-3c0ib";
              label = "ala-an70/default";
              devices = [ "ala_an70" ];
            };
            "${pubdir}/ala-an70/pics" = {
              id = "mjwxp-9joch";
              type = "receiveonly";
              label = "ala-an70/pics";
              devices = [ "ala_an70" ];
            };
            "${pubdir}/ala-an70/camera" = {
              id = "ala-an70_pam5-照片";
              type = "receiveonly";
              label = "ala-an70/camera";
              devices = [ "ala_an70" ];
            };
            "${pubdir}/matepad23/camera" = {
              id = "dbr-w10_qv9a-照片";
              type = "receiveonly";
              label = "matepad23/camera";
              devices = [ "matepad23" ];
            };
            "${pubdir}/matepad23/screenshots" = {
              id = "qe97y-ilta4";
              type = "receiveonly";
              label = "matepad23/screenshots";
              devices = [ "matepad23" ];
            };
            "${pubdir}/hw-p60/camera" = {
              id = "lna-al00_pyqc-照片";
              type = "receiveonly";
              label = "hw-p60/camera";
              devices = [ "hw_p60" ];
            };
            "${pubdir}/hw-p60/pics" = {
              id = "dfyrd-94rbb";
              type = "receiveonly";
              label = "hw-p60/pics";
              devices = [ "hw_p60" ];
            };
          };
          devices = {
            gtr7.id = "DYFRCJJ-7WNW3GF-XHTLMH3-2UBZ2TR-6KGAAAD-APLJK6F-GCVZQEJ-OWNC7QQ";
            matepad23.id = "VQKKXIY-JESAFSW-TE5MXQF-ND3H7IR-FKL357O-ZWNYPTP-O5OSKUC-Y4XK2AU";
            ala_an70.id = "6EBVCNG-JWOCLAQ-QWLUM73-4E3C2GY-FGDVWP3-P563Q3D-X62YMIN-5FILAA5";
            xps13_9360.id = "HJBCABV-UZBQV5P-V552XA2-B4D7DH5-T2WCHRS-I55ONAS-V6AB332-GKQ67Q4";
            hw_p60.id = "DVCK2UK-VYORBXG-LUR3444-OOYIEUU-P7E6KPD-5KTFNCZ-SFUIDXI-27LUFQO";
          };
        };
      };
  };
}
