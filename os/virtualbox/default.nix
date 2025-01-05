{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.virtualbox;
in
{
  options.fool.virtualbox = {
    enable = mkEnableOption "virtualbox";
    guest-enable = mkEnableOption "nixos在虚拟机中";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      nixpkgs.config.allowUnfree = true; # for enableExtensionPack
      virtualisation.virtualbox.host = {
        enable = true;
        enableExtensionPack = true;
      };
    })
    (mkIf cfg.guest-enable {
      virtualisation.virtualbox.guest = {
        enable = true;
      };
    })
  ];
}
