{
  pkgs,
  lib,
  hmConfig,
  ...
}:
lib.mkIf hmConfig.fool.nvim.ai {
  extraPlugins = [
    { plugin = pkgs.vimPlugins.avante-nvim; }
  ];
}
