{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  options.fool.nvim = {
    lsp = lib.mkEnableOption "Language Server Protocol";
    ai = lib.mkEnableOption "AI editor plugins";
  };

  config = {
    programs.nixvim = {
      enable = true;
      nixpkgs.source = inputs.nixpkgs;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = true;
      withPython3 = true;
      wrapRc = true;
      impureRtp = false;
      enablePrintInit = true;
      imports = [
        (import ./base.nix {
          inherit pkgs lib;
          inherit (config.home) homeDirectory;
        })
        ./lsp.nix
        ./ai.nix
      ];
    };

    home.packages =
      with pkgs;
      [
        fzf
        fd # for fzf respect gitignore
        lemonade
        neovim-remote
        gitmoji-cli
        nixfmt # formatter used by nil_ls
      ];

    xdg.enable = true;
  };
}
