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

  config = mkMerge [
    (mkIf cfg.with-skim {
      # skim integration 依赖 zsh 已启用；否则 programs.skim 的
      # enableZshIntegration 没有宿主 shell，属于无效组合。
      assertions = [
        {
          assertion = cfg.enable;
          message = "fool.zsh.with-skim requires fool.zsh.enable";
        }
      ];
      programs.skim = {
        enable = true;
        enableZshIntegration = true;
      };
    })
  ];
}