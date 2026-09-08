{
  config,
  pkgs,
  lib,
  hmConfig,
  ...
}:
let
  raw = expr: { __raw = expr; };
in
lib.mkIf hmConfig.fool.nvim.lsp {
  extraPlugins = with pkgs.vimPlugins; [
    { plugin = fzf-lsp-nvim; }
  ];

  plugins.lsp = {
    enable = true;
    servers = {
      # 每个 server 启用 nixvim 默认 package（来自 packages.nix 映射），
      # 不再设 package = null 或维护 home.packages 第二清单。
      # ccls→clangd 已纠正：clangd 默认包为 clang-tools（含 clangd 二进制）。
      jsonls = { enable = true; };
      html = { enable = true; };
      cssls = { enable = true; };
      pylsp = { enable = true; };
      bashls = { enable = true; };
      clangd = { enable = true; };
      eslint = { enable = true; };
      vimls = { enable = true; };
      marksman = { enable = true; };
      perlpls = { enable = true; };
      nil_ls = {
        enable = true;
        settings.formatting.command = [ "nixfmt" ];
      };
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
        installRustfmt = false;
        settings = {
          checkOnSave = true;
          cargo.loadOutDirsFromCheck = true;
          procMacro.enable = true;
          check = {
            command = "clippy";
            extraArgs = [
              "--"
              "-D"
              "warnings"
              "-W"
              "clippy::pedantic"
              "-W"
              "clippy::nursery"
              "-W"
              "rust-2018-idioms"
            ];
          };
        };
      };
      lua_ls = {
        enable = true;
        settings = {
          runtime.version = "LuaJIT";
          diagnostics.globals = [ "vim" ];
          workspace = {
            library = raw ''vim.api.nvim_get_runtime_file("", true)'';
            checkThirdParty = false;
          };
          telemetry.enable = false;
          format = {
            enable = true;
            defaultConfig = {
              indent_style = "space";
              indent_size = "2";
            };
          };
        };
      };
    };

    onAttach = ''
      if client:supports_method('textDocument/completion') then
        local chars = { '.', '>' };
        client.server_capabilities.completionProvider.triggerCharacters = chars
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
        vim.keymap.set('i', '<C-M-i>', function() vim.lsp.completion.get() end)
      end

      local opts = { buffer = bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', '<Bslash>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<Bslash>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<Bslash>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set('n', '<Bslash>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)

      if not client:supports_method('textDocument/willSaveWaitUntil')
          and client:supports_method('textDocument/formatting') then
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
          end,
        })
      end
    '';
  };

  plugins.treesitter = {
    enable = true;
    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      lalrpop
      just
      toml
      textproto
    ];
  };

  globals.polyglot_disabled = lib.mkForce [
    "autoindent"
    "toml.plugin"
  ];

  autoGroups.TS_enable.clear = true;

  autoCmd = [
    {
      event = "FileType";
      group = "TS_enable";
      pattern = [
        "textproto"
        "lalrpop"
      ];
      callback = raw "function() vim.treesitter.start() end";
    }
  ];

  keymaps = [
    {
      mode = "n";
      key = "<Bslash>e";
      action = raw "vim.diagnostic.open_float";
    }
    {
      mode = "n";
      key = "[d";
      action = raw "function() vim.diagnostic.jump({ count = -1, float = true }) end";
    }
    {
      mode = "n";
      key = "]d";
      action = raw "function() vim.diagnostic.jump({ count = 1, float = true }) end";
    }
    {
      mode = "n";
      key = "<Bslash>q";
      action = raw "vim.diagnostic.setloclist";
    }
  ];

  extraConfigLuaPost = lib.mkOrder 1000 ''
    require 'fzf_lsp'.setup()
  '';
}