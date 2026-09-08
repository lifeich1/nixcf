{ lib, homeDirectory, ... }:
with lib;
{
  autoGroups = {
    GitEmoji.clear = true;
  };

  autoCmd = [
    {
      event = "BufEnter";
      group = "GitEmoji";
      pattern = "COMMIT_EDITMSG";
      callback = { __raw = ''
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
      ''; };
    }
  ];

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

  extraConfigLuaPost = mkOrder 1500 ''
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