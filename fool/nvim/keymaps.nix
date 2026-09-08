{ lib, ... }:
let
  raw = expr: { __raw = expr; };

  keymap = mode: key: action: {
    inherit mode key action;
    options = {
      noremap = true;
      silent = false;
    };
  };
in
{
  keymaps = [
    (keymap "" "<Up>" "gk")
    (keymap "" "<Down>" "gj")
    (keymap "i" "<F2>" "<Esc>:w<CR>a")
    (keymap "n" "<leader>w" ":match Error /\\ \\+$/<CR>")
    (keymap "n" "<leader>W" ":match none<CR>")
    (keymap "n" "<leader>kj" ":set keymap=workman-p<CR>")
    (keymap "n" "<leader>kk" ":set keymap=<CR>")
    (keymap "n" "<leader>ya" ":%y<CR>")
    (keymap "n" "<leader>c5" ":let @+=@%<CR>")
    (keymap "n" "<leader>nd" ":execute ':packadd nerdtree | NERDTreeToggle'<CR>")
    (keymap "n" "<leader>po" ":echo \"this_obsession: \" . g:this_obsession<CR>")
    (keymap "n" "<leader>o" ":Files<CR>")
    (keymap "n" "<leader>zt" ":BTags<CR>")
    (keymap "n" "<leader>zT" ":Tags<CR>")
    (keymap "n" "<leader>zb" ":Buffers<CR>")
    (keymap "n" "<leader>zw" ":Windows<CR>")
    (keymap "n" "<leader>zd" ":GFiles?<CR>")
    (keymap "n" "<leader>gg" ":execute ':packadd vim-grepper | Grepper'<CR>")
    (keymap "n" "<M-h>" "<C-w><C-h>")
    (keymap "n" "<M-j>" "<C-w><C-j>")
    (keymap "n" "<M-k>" "<C-w><C-k>")
    (keymap "n" "<M-l>" "<C-w><C-l>")
    (keymap "i" "<M-h>" "<Esc><C-w><C-h>")
    (keymap "i" "<M-j>" "<Esc><C-w><C-j>")
    (keymap "i" "<M-k>" "<Esc><C-w><C-k>")
    (keymap "i" "<M-l>" "<Esc><C-w><C-l>")
    (keymap "n" "<M-->" "gT")
    (keymap "n" "<M-=>" "gt")
    (keymap "i" "<M-->" "<Esc>gT")
    (keymap "i" "<M-=>" "<Esc>gt")
    (keymap "n" "<M-9>" ":-tabmove<CR>")
    (keymap "n" "<M-0>" ":+tabmove<CR>")
    (keymap "i" "<M-9>" "<Esc>:-tabmove<CR>")
    (keymap "i" "<M-0>" "<Esc>:+tabmove<CR>")
    (keymap "t" "<Esc>" "<C-\\><C-n>")
    (keymap "t" "<C-v><Esc>" "<Esc>")
    (keymap "t" "<M-h>" "<C-\\><C-n><C-w><C-h>")
    (keymap "t" "<M-j>" "<C-\\><C-n><C-w><C-j>")
    (keymap "t" "<M-k>" "<C-\\><C-n><C-w><C-k>")
    (keymap "t" "<M-l>" "<C-\\><C-n><C-w><C-l>")
    (keymap "t" "<M-->" "<C-\\><C-n>gT")
    (keymap "t" "<M-=>" "<C-\\><C-n>gt")
    (keymap "t" "<M-9>" "<C-\\><C-n>:-tabmove<CR>")
    (keymap "t" "<M-0>" "<C-\\><C-n>:+tabmove<CR>")
    {
      mode = "n";
      key = "zR";
      action = raw "require('ufo').openAllFolds";
    }
    {
      mode = "n";
      key = "zM";
      action = raw "require('ufo').closeAllFolds";
    }
    {
      mode = "n";
      key = "zr";
      action = raw "require('ufo').openFoldsExceptKinds";
    }
    {
      mode = "n";
      key = "zm";
      action = raw "require('ufo').closeFoldsWith";
    }
    {
      mode = "n";
      key = "K";
      action = raw ''
        function()
          local winid = require('ufo').peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end
      '';
    }
  ];

  files."keymap/workman-p.vim".extraConfigVim = builtins.readFile ./workman-p.vim;
}