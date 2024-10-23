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
  minpac = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      pname = "minpac";
      version = "2024-07-31";
      src = pkgs.fetchFromGitHub {
        owner = "k-takata";
        repo = "minpac";
        rev = "caa090e10ed55f20a3a6f2df822d1a9967d151d0";
        hash = "sha256-gAyR6Lgimzkgy+zQs0S80U4wASeUU6lM7ecxA7e4Tiw=";
      };
    };
    optional = true;
  };
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
        plugins =
          [
            minpac
          ]
          ++ (with pkgs.vimPlugins; [
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
          ]);
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
        python312Packages.python-lsp-server
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
