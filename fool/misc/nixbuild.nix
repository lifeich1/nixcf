{
  config,
  lib,
  pkgs,
  ...
}@all:
with lib;
let
  cfg = config.fool.misc;
in
{
  options.fool.misc = {
    nixbuild = mkEnableOption "install nix related tools";
  };

  config = mkIf cfg.nixbuild {
    home.packages =
      with pkgs;
      [
        # it provides the command `nom` works just like `nix`
        # with more details log output
        nix-output-monitor
        colmena
        nvd
        nixpkgs-review
        nix-du
      ]
      ++ [ all.inputs.agenix.packages."${all.system}".default ];
  };
}
