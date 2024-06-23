{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.fool.hobob;
in
{
  options.fool.hobob = {
    overlay = mkEnableOption "hobob overlay";
  };
  config = mkIf cfg.overlay {
    nixpkgs.overlays = [ (final: prev: { hobob = inputs.hobob.packages."${prev.system}".default; }) ];

  };
}
