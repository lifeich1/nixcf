{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
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
        nvd
        nixpkgs-review
        nix-du
      ]
      ++ [ inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default ];
  };
}
