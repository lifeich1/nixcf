{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.fool.nvim;
  minpac = pkgs.vimUtils.buildVimPlugin {
    pname = "minpac";
    version = inputs.minpac.lastModifiedDate;
    src = inputs.minpac;
  };
in
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
          inherit pkgs lib minpac;
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
      ]
      ++ lib.optionals cfg.lsp [
        nil
        nixfmt
        rust-analyzer
        lua-language-server
        vim-language-server
        bash-language-server
        perl5Packages.PLS
        marksman
        vscode-langservers-extracted
        python312Packages.python-lsp-server
        ccls
      ];

    xdg.enable = true;
  };
}
