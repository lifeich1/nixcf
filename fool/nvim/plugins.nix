{ pkgs, lib, ... }:
let
  raw = expr: { __raw = expr; };
  opt = plugin: { inherit plugin; optional = true; };
  start = plugin: { inherit plugin; };
in
{
  extraPlugins = with pkgs.vimPlugins; [
    (start vim-dispatch)
    (start vim-obsession)
    (start vim-projectionist)
    (start vim-fugitive)
    (start bufexplorer)
    (start plenary-nvim)
    (start promise-async)
    (start fzf-vim)
    (opt vim-polyglot)
    (opt gruvbox)
    (opt vim-startuptime)
    (opt nerdtree)
    (opt seoul256-vim)
    (opt vim-grepper)
  ];

  plugins.coverage = {
    enable = true;
    settings.lang.rust = {
      coverage_command = "cargo run -r -q --package xtask -- coverage --neo";
      project_files_only = false;
    };
  };

  plugins.nvim-ufo = {
    enable = true;
    settings.preview = {
      win_config = {
        border = [
          ""
          "─"
          ""
          ""
          ""
          "─"
          ""
          ""
        ];
        winhighlight = "Normal:Folded";
        winblend = 0;
      };
      mappings = {
        scrollU = "<C-u>";
        scrollD = "<C-d>";
        jumpTop = "[";
        jumpBot = "]";
      };
    };
  };

  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "frappe";
      transparent_background = true;
      term_colors = true;
      highlight_overrides.all = raw ''
        function(colors)
          return {
            StatusLine = { bg = colors.mantle },
            StatusLineNC = { bg = colors.crust },
          }
        end
      '';
    };
  };
}