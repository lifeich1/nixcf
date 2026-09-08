{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.fastfetch;
in
{
  options.fool.fastfetch = {
    enable = mkEnableOption "fastfetch";
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "fastfetch settings, passed to programs.fastfetch.settings";
    };
  };

  # 模块同时拥有 package 与 config（经由 Home Manager programs.fastfetch），
  # 不再依赖其他模块安装 executable。
  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      settings = cfg.settings;
    };
  };
}