{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.zsh;
in
{
  options.fool.zsh = {
    with-skim = mkEnableOption "skim zsh integration";
  };

  config = mkIf cfg.with-skim {
    programs.skim = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
