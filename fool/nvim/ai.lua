require('aider').setup({
  auto_manage_context = false,
  default_bindings = true,
  debug = false,
  -- ignore_buffers = {},
  border = {
    style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- or e.g. "rounded"
    color = "#fab387",
  },

  -- only necessary if you want to change the default keybindings. <Leader>C is not a particularly good choice. It's just shown as an example.
  -- vim.api.nvim_set_keymap('n', '<leader>C', ':AiderOpen --no-auto-commits<CR>', {noremap = true, silent = true})
})
