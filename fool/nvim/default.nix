{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.fool.nvim;
in
{
  options.fool.nvim = {
    # default enabled
    lsp = mkEnableOption "Language Server Protocol";
  };

  config = mkMerge [
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          vim-dispatch
          vim-obsession
          vim-projectionist
          vim-fugitive
          vim-polyglot
          bufexplorer
          plenary-nvim
          promise-async
          nvim-ufo
          nvim-coverage
          fzf-vim
        ];
      };

      home.packages = with pkgs; [
        fzf
        fd # for fzf respect gitignore
        lemonade
        neovim-remote
        gitmoji-cli
      ];

      home.file.".vimrc".source = ./vimrc;
      home.file.".vim/init.lua".source = ./init.lua;
      home.file.".vim/pack/minpac/opt/minpac".source = inputs.vim-minpac;
      xdg.enable = true;
      xdg.configFile."nvim/init.vim".source = ./init.vim;
    }
    (mkIf cfg.lsp {
      home.packages = with pkgs; [
        nil
        statix
        #nixpkgs-fmt # beta, dying
        nixfmt-rfc-style # unstable
        clang-tools_17
        rust-analyzer
        lua-language-server
        vim-language-server
        bash-language-server
        perl538Packages.PLS
        marksman
        vscode-langservers-extracted
      ];

      programs.neovim.plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        fzf-lsp-nvim
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            lalrpop
            just
            toml
          ]
        ))
      ];

      home.file.".lintd/nvim/lsp.lua".source = ./lsp.lua;
    })
  ];
}
