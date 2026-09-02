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
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true; # for enableExtensionPack
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      enableKvm = true;
      addNetworkInterface = false; # bind with enableKvm
    };
  };
}
