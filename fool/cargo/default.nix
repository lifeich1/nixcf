{ config, lib, ... }:
with lib;
let
  cfg = config.fool.cargo;
in
{
  options.fool.cargo = {
    ctrl-config = mkEnableOption "control $HOME/.cargo/config.toml";
  };

  config = mkIf cfg.ctrl-config {
    home.file.".cargo/config.toml".source = ./config.toml;
  };
}
