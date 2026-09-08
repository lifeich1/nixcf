{
  pkgs,
  lib,
  minpac,
  homeDirectory,
}:
let
  opt = plugin: {
    inherit plugin;
    optional = true;
  };

  start = plugin: { inherit plugin; };

  keymap = mode: key: action: {
    inherit mode key action;
    options = {
      noremap = true;
      silent = false;
    };
  };

  raw = expr: { __raw = expr; };
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
    (opt minpac)
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

  globals = {
    mapleader = " ";
    maplocalleader = "\\";
    polyglot_disabled = [ "autoindent" ];
    fzf_buffers_jump = 1;
  };

  opts = {
    expandtab = true;
    tabstop = 2;
    shiftwidth = 2;
    softtabstop = -1;
    backspace = [
      "eol"
      "start"
      "indent"
    ];
    ruler = true;
    compatible = false;
    showcmd = true;
    fileencodings = [
      "utf-8"
      "gbk"
      "latin1"
    ];
    modelines = 5;
    sessionoptions = [
      "buffers"
      "curdir"
      "help"
      "tabpages"
      "terminal"
      "winsize"
    ];
    foldlevel = 99;
    foldenable = true;
    foldcolumn = "1";
    foldlevelstart = 99;
    completeopt = [
      "menuone"
      "noinsert"
      "fuzzy"
    ];
    clipboard = [ "unnamedplus" ];
    keymap = "workman-p";
  };

  autoGroups = {
    py_iden.clear = true;
    GitEmoji.clear = true;
  };

  autoCmd = [
    {
      event = "BufEnter";
      group = "py_iden";
      pattern = "*.py";
      command = "setlocal tabstop=4 shiftwidth=4";
    }
    {
      event = "BufEnter";
      group = "GitEmoji";
      pattern = "COMMIT_EDITMSG";
      callback = raw ''
        function(ev)
          local opts = { buffer = ev.buf }
          local sink_fun = function(a)
            vim.api.nvim_echo({ { string.format('buf %d, sink fun %s', ev.buf, a), "MoreMsg" } }, true, {})
            for moji in string.gmatch(a, "(:[%w_]+:)") do
              local t = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1]
              vim.api.nvim_echo({ { string.format('moji %s, line %s', moji, t), "MoreMsg" } }, true, {})
              local y
              if type(t) == 'string' and string.len(t) > 0 then
                y = t .. moji .. " "
              else
                y = moji .. " "
              end
              vim.api.nvim_buf_set_lines(ev.buf, 0, 1, false, { y })
            end
          end
          local call_fzf = function()
            if vim.fn.has('fzf#run') then
              local arg = vim.fn["fzf#wrap"]({
                source = "gitmoji -l",
                sink = sink_fun,
              })
              vim.fn["fzf#run"](arg)
            else
              vim.api.nvim_echo({ { 'fzf#run not found' } }, true, { err = true })
            end
          end
          vim.keymap.set('n', '<leader>j', call_fzf, opts)
          vim.keymap.set('i', '<C-J>', call_fzf, opts)
        end
      '';
    }
  ];

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

  extraConfigVim = ''
    filetype plugin indent on
    syntax on

    iabbrev @mail@ lintd23@outlook.com
    iabbrev @gmail@ lifeich0@gmail.com
    iabbrev <expr> @now@ strftime("%F %T %z")

    iabbrev !tt! int tt; cin >> tt; while (tt--)

    iabbrev !fori! for (int i = 0; i < n; ++i)
    iabbrev !forij! for (int i = 0; i < n; ++i) for (int j = 0; j < m; ++j)
    iabbrev !forj! for (int j = 0; j < m; ++j)
    iabbrev !fork! for (int k = 0; k < n; ++k)

    iabbrev !l! [&](
    iabbrev !vi! std::vector<int>
    iabbrev !vi64! std::vector<int64_t>
    iabbrev !vsz! std::vector<std::size_t>
    iabbrev !bi! std::back_inserter()
    iabbrev !b! .begin()
    iabbrev !e! .end()
    iabbrev !pb! .emplace_back

    iabbrev !iit! istream_iterator(cin)
    iabbrev !oit! ostream_iterator(cout)

    iabbrev !py! from random import randint as r
    iabbrev !pr! for _ in range()
    iabbrev !sh! #!/usr/bin/env bash
    iabbrev !chk! i=1; while :; do python ./gen.py > c.in && ./force <c.in >c.ans && ./main.cc.exe <c.in >c.out && printf "%s ok\r" $i \|\| break; i=$((i+1)); done

    function! s:MinpacPrepare() abort
      packadd minpac
      call minpac#init()
      " manage by nix
      "call minpac#add('k-takata/minpac', {'type': 'opt'})

      " minpac managing plugins (cannot manager by nix) {{{
      " }}}
    endfunction

    command! PkgUpd call s:MinpacPrepare() | call minpac#update()
    command! PkgCl call s:MinpacPrepare() | call minpac#clean()
    command! PkgSt call s:MinpacPrepare() | call minpac#status()

    let $FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix"

    command Tclr2m execute tabpagenr()+1 . ",$tabdo tabcl"

    highlight CoverageCovered ctermfg=green
    highlight CoverageUncovered ctermfg=darkred
    highlight CoveragePartial ctermfg=lightblue

    if filereadable("${homeDirectory}/opt/miniconda3/bin/python3")
      let g:python3_host_prog="${homeDirectory}/opt/miniconda3/bin/python3"
    endif
    if filereadable("${homeDirectory}/opt/perl5/perlbrew/perls/perl-5.34.1/bin/perl")
      let g:perl_host_prog="${homeDirectory}/opt/perl5/perlbrew/perls/perl-5.34.1/bin/perl"
    endif

    cnoremap <Bslash>at RSPCAutoTest<cr>
    cnoremap <Bslash>qt !rm keeptest<cr>
  '';

  extraConfigLuaPost = lib.mkOrder 1500 ''
    vim.filetype.add({
      extension = {
        lalrpop = function(path, bufnr)
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          return 'lalrpop'
        end,
      },
      pattern = {
        ['.*%.json%.age'] = "json",
        ['.*%.pb%.txt'] = {
          function(path, bufnr)
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            return 'textproto'
          end,
          { priority = 10 },
        },
      },
    })

    if vim.env.SSH_CLIENT then
      vim.g.clipboard = {
        name = 'OSC52_cp/lemonade',
        copy = {
          ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
          ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
        },
        paste = {
          ['+'] = { 'lemonade', 'paste' },
          ['*'] = { 'lemonade', 'paste' },
        },
        cache_enabled = 1,
      }
    end

    local addon = vim.env.HOME .. "/.lintd/nvim/addon.lua"
    if vim.fn.filereadable(addon) == 1 then
      dofile(addon)
    end
  '';
}
