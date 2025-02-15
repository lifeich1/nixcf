-- require("nvim-lsp-installer").setup {}
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

local lspconfig = require('lspconfig')

lspconfig.nil_ls.setup {
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
}

lspconfig.ccls.setup {
  init_options = {
    cache = {
      directory = os.getenv("HOME") .. "/.ccls-cache",
    },
    index = {
      threads = 4,
      trackDependency = 0,
    },
    clang = {
      excludeArgs = { "-frounding-math" },
    },
  }
}

lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
      check = {
        command = "clippy",
        extraArgs = { "--", "-D", "warnings", "-W", "clippy::pedantic", "-W", "clippy::nursery", "-W",
          "rust-2018-idioms" },
      },
      -- ["rust-analyzer.cargo.loadOutDirsFromCheck"] = true,
      -- ["rust-analyzer.procMacro.enable"] = true,
      -- ["rust-analyzer.check.command"] = "clippy",
    },
  },
}
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        -- Put format options here
        -- NOTE: the value should be STRING!!
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
    },
  },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<Bslash>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
vim.keymap.set('n', '<Bslash>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<Bslash>i', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<Bslash>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<Bslash>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<Bslash>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<Bslash>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<Bslash>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Bslash>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<Bslash>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set('n', '<Bslash>zt', vim.lsp.buf.document_symbol, opts)

    if client ~= nil and client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format {}
        end,
      })
    end
  end,
})

-- local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
local language_servers = {
  'jsonls', 'html', 'cssls', 'pylsp', 'bashls',
  'eslint', 'vimls', 'marksman', 'perlpls' }
for _, ls in ipairs(language_servers) do
  require('lspconfig')[ls].setup({
    capabilities = capabilities
    -- you can add other fields for setting up lsp server in this table
  })
end

require 'fzf_lsp'.setup()

require 'nvim-treesitter.configs'.setup {
  modules = {},
  ensure_installed = {},
  sync_install = false,
  auto_install = false,
  ignore_install = { "all" },

  highlight = {
    enable = true,

    ---@diagnostic disable-next-line: unused-local
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      ---@diagnostic disable-next-line: undefined-field
      local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
      if stats and stats.size > max_filesize then
        return true
      end
    end,

    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  }
}

-- disable polyglot, use treesitter
vim.g.polyglot_disabled = { "autoindent", "toml.plugin" }
