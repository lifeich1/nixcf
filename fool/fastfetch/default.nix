{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.fastfetch;
in
{
  options.fool.fastfetch = {
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "fastfetch jsonc config file";
    };
  };

  config = mkIf (isPath cfg.configFile) {
    xdg.enable = true;
    xdg.configFile."fastfetch/config.jsonc" = {
      source = cfg.configFile;
    };
  };
}
