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
  minpac = pkgs.vimUtils.buildVimPlugin {
    pname = "minpac";
    version = inputs.minpac.lastModifiedDate;
    src = inputs.minpac;
  };
  optionalPlug =
    plugs:
    (map (plug: {
      plugin = plug;
      optional = true;
    }) plugs);
in
{
  options.fool.nvim = {
    # default enabled
    lsp = mkEnableOption "Language Server Protocol";
    nightly = mkEnableOption "use nightly neovim";
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
          with pkgs.vimPlugins;
          ([
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
          ])
          ++ (optionalPlug [
            minpac
            gruvbox
            vim-startuptime
            nerdtree
            seoul256-vim
            vim-grepper
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
        #nixpkgs-fmt # beta, dying
        nixfmt-rfc-style # unstable
        rust-analyzer
        lua-language-server
        vim-language-server
        bash-language-server
        perl538Packages.PLS
        marksman
        vscode-langservers-extracted
        python312Packages.python-lsp-server
        ccls
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
    (mkIf cfg.nightly {
      # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
      programs.neovim.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    })
  ];
}
