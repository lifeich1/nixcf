{
  pkgs,
  lib,
  hmConfig,
  ...
}:
lib.mkIf hmConfig.fool.nvim.lsp {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    fzf-lsp-nvim
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        lalrpop
        just
        toml
        textproto
      ]
    ))
  ];

  extraConfigLuaPost = lib.mkOrder 1000 (builtins.readFile ./lsp.lua);
}
