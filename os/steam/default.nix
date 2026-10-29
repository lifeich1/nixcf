# Steam + GE-Proton（仅 GTR7 桌面启用）。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fool.steam;
in
{
  options.fool.steam = {
    enable = lib.mkEnableOption "Steam with GE-Proton";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      # proton-ge-bin 的 steamcompattool output 由上游 module 注入
      # STEAM_EXTRA_COMPAT_TOOLS_PATHS，重启 Steam 后可直接选择 GE-Proton。
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };
}
