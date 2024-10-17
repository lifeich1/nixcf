require("coverage").setup({
  lang = {
    rust = {
      coverage_command = "cargo run -r -q --package xtask -- coverage --neo",
      project_files_only = false,
    },
  },
})

require('ufo').setup({
  preview = {
    win_config = {
      border = { '', '─', '', '', '', '─', '', '' },
      winhighlight = 'Normal:Folded',
      winblend = 0
    },
    mappings = {
      scrollU = '<C-u>',
      scrollD = '<C-d>',
      jumpTop = '[',
      jumpBot = ']'
    }
  },
})

vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
vim.keymap.set('n', 'K', function()
  local winid = require('ufo').peekFoldedLinesUnderCursor()
  if not winid then
    -- choose one of coc.nvim and nvim lsp
    vim.lsp.buf.hover()
  end
end)

require("catppuccin").setup({
  flavour = "frappe",
  transparent_background = true,
  term_colors = true,
  highlight_overrides = {
    all = function(colors)
      return {
        StatusLine = { bg = colors.mantle },
        StatusLineNC = { bg = colors.crust },
      }
    end,
  },
})
vim.cmd.colorscheme "catppuccin"

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

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('GitEmoji', {}),
  pattern = { "COMMIT_EDITMSG" },
  callback = function(ev)
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
    --vim.api.nvim_buf_create_user_command(ev.buf, "SinkGitEmoji", sink_fun, { nargs = 1 })
    local call_fzf = function()
      if vim.fn.has('fzf#run') then
        local arg = vim.fn["fzf#wrap"]({
          source = "gitmoji -l",
          sink = sink_fun,
        })
        vim.fn["fzf#run"](arg)
      else
        vim.api.nvim_err_writeln('fzf#run not found')
      end
    end
    vim.keymap.set('n', '<leader>j', call_fzf, opts);
    vim.keymap.set('i', '<C-J>', call_fzf, opts);
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('json_age', {}),
  pattern = { "*.json.age" },
  callback = function(ev)
    vim.opt_local.filetype = 'json';
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('ft_lalrpop', {}),
  pattern = { "*.lalrpop" },
  callback = function(ev)
    vim.opt_local.filetype = 'lalrpop';
  end,
})
