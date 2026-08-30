{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fool.reasonix;
in
{
  options.fool.reasonix.enable = lib.mkEnableOption "Reasonix CLI";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "fool.reasonix supports only x86_64-linux";
      }
    ];

    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
