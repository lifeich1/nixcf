# desktop collection：NetworkManager + Plasma（含 KDE Connect、fcitx5 等）。
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.collections;
in
{
  options.fool.collections = {
    desktop = mkEnableOption "desktop collection: NetworkManager + Plasma";
  };

  config = mkIf cfg.desktop {
    networking.networkmanager.enable = true;
    fool.plasma.enable = true;
  };
}
