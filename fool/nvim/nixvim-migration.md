# Neovim 配置迁移到 nixvim 方案

## 概述

本文档提供了将现有 Neovim 配置从传统的 Vimscript/Lua 文件迁移到 [nixvim](https://github.com/nix-community/nixvim) 框架的详细方案。nixvim 是一个用 Nix 声明式配置 Neovim 的框架，支持插件管理、LSP 配置、键盘映射等。

## 当前配置分析

当前配置位于 `fool/nvim/` 目录下，包含以下文件：

| 文件 | 内容 | 大小/行数 |
|------|------|-----------|
| `default.nix` | Nix 模块配置，管理插件和选项 | 100+ 行 |
| `init.vim` | 主入口文件，加载其他配置 | 56 行 |
| `vimrc` | 传统 Vim 配置（基本设置、键盘映射、缩写） | 161 行 |
| `init.lua` | Lua 配置（UFO、主题、Git 集成、文件类型检测） | 128 行 |
| `lsp.lua` | LSP 配置（语言服务器设置） | 155 行 |
| `workman-p.vim` | Workman 键盘布局映射 | 104 行 |
| `nvim-config-skills.md` | 配置技能总结文档 | - |

### 主要功能特性

1. **插件管理**：通过 Nix 包管理器安装插件，使用 minpac 管理可选插件
2. **LSP 支持**：配置多种语言服务器（Rust、Nix、Lua、Python 等）
3. **代码折叠**：使用 nvim-ufo 提供高级折叠功能
4. **主题**：Catppuccin frappe 主题，支持透明背景
5. **键盘映射**：丰富的领导键映射，Workman 键盘布局支持
6. **Git 集成**：vim-fugitive 和 gitmoji-cli 集成
7. **文件查找**：fzf + fd 实现快速文件导航
8. **环境感知**：SSH 环境下自动使用 OSC52 剪贴板
9. **代码覆盖率**：nvim-coverage 插件支持
10. **Tree-sitter**：语法高亮和文件类型检测

## nixvim 简介

nixvim 是一个基于 Nix 的 Neovim 配置框架，提供以下特性：

- **声明式配置**：所有配置在 Nix 中定义
- **插件管理**：自动处理插件依赖和加载
- **模块化设计**：可组合的配置模块
- **LSP 集成**：内置语言服务器配置支持
- **自动生成**：从 Nix 配置生成 init.lua/init.vim

## 迁移策略

### 方案选择：混合迁移

考虑到现有配置的复杂性，建议采用**混合迁移策略**：

1. **第一阶段**：创建基础 nixvim 配置，管理插件和基本设置
2. **第二阶段**：将 Lua 配置逐步迁移到 nixvim 原生配置
3. **第三阶段**：完全迁移，移除传统配置文件

### 迁移优先级

1. **高优先级**：插件管理、基本设置、键盘映射
2. **中优先级**：LSP 配置、主题设置、环境特定配置
3. **低优先级**：高级 Lua 功能、自定义自动命令

## 详细迁移步骤

### 步骤 1：创建 nixvim 模块

创建 `fool/nvim/nixvim.nix` 文件，作为主要的 nixvim 配置模块：

```nix
{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;

    # 基础配置
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    # 插件配置
    plugins = {
      # 插件列表
    };

    # Vim 选项
    options = {
      # 选项设置
    };

    # 键盘映射
    keymaps = [
      # 映射列表
    ];

    # 全局变量
    globals = {
      # 全局变量设置
    };

    # 自动命令
    autoCmd = [
      # 自动命令列表
    ];

    # Lua 配置
    extraConfigLua = ''
      -- 额外的 Lua 配置
    '';

    # Vimscript 配置
    extraConfigVim = ''
      " 额外的 Vimscript 配置
    '';
  };
}
```

### 步骤 2：插件迁移

将现有插件列表从 `default.nix` 迁移到 nixvim 的 `plugins` 选项：

**当前插件分类**：
- 必需插件：catppuccin-nvim, vim-dispatch, vim-obsession, vim-projectionist, vim-fugitive, bufexplorer, plenary-nvim, promise-async, nvim-ufo, nvim-coverage, fzf-vim
- 可选插件：vim-polyglot, minpac, gruvbox, vim-startuptime, nerdtree, seoul256-vim, vim-grepper
- LSP 相关：nvim-lspconfig, fzf-lsp-nvim, nvim-treesitter
- AI 相关：avante-nvim

**nixvim 插件配置示例**：

```nix
plugins = {
  # 主题
  catppuccin = {
    enable = true;
    flavour = "frappe";
    transparentBackground = true;
  };

  # 代码折叠
  ufo = {
    enable = true;
    # UFO 配置
  };

  # LSP
  lsp = {
    enable = true;
    servers = {
      # 语言服务器配置
    };
  };

  # Tree-sitter
  treesitter = {
    enable = true;
    # 语法支持
  };

  # 其他插件
  fugitive.enable = true;
  fzf-lua.enable = true;  # 替代 fzf-vim
  # ... 其他插件
};
```

### 步骤 3：基本设置迁移

将 `vimrc` 中的基本设置迁移到 `options`：

```nix
options = {
  # 缩进设置
  expandtab = true;
  tabstop = 2;
  shiftwidth = 2;
  softtabstop = -1;  # 使用 shiftwidth

  # 界面设置
  ruler = true;
  showcmd = true;
  number = true;
  relativenumber = true;

  # 文件编码
  fileencoding = "utf-8";
  encoding = "utf-8";

  # 折叠
  foldlevel = 99;
  foldenable = true;
  foldcolumn = "1";
  foldlevelstart = 99;

  # 其他
  backspace = [ "eol", "start", "indent" ];
  clipboard = "unnamedplus";
  completeopt = [ "menuone", "noinsert", "fuzzy" ];
};
```

### 步骤 4：键盘映射迁移

将 `vimrc` 和 `init.vim` 中的键盘映射转换为 nixvim 的 `keymaps`：

```nix
keymaps = [
  # 领导键设置
  {
    mode = "n";
    key = "<Space>";
    action = "<Nop>";
    options = {
      silent = true;
      noremap = true;
    };
  }

  # 基本映射
  {
    mode = "n";
    key = "<Up>";
    action = "gk";
  }
  {
    mode = "n";
    key = "<Down>";
    action = "gj";
  }
  {
    mode = "i";
    key = "<F2>";
    action = "<Esc>:w<CR>a";
  }

  # 窗口导航
  {
    mode = [ "n", "i" ];
    key = "<M-h>";
    action = "<C-w>h";
  }
  # ... 更多映射
];
```

### 步骤 5：Lua 配置迁移

#### 5.1 UFO 配置迁移

```nix
plugins.ufo = {
  enable = true;
  preview = {
    winConfig = {
      border = [ "", "─", "", "", "", "─", "", "" ];
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

keymaps = [
  # UFO 键盘映射
  {
    mode = "n";
    key = "zR";
    lua = true;
    action = "require('ufo').openAllFolds";
  },
  # ... 其他 UFO 映射
];
```

#### 5.2 主题配置迁移

```nix
plugins.catppuccin = {
  enable = true;
  flavour = "frappe";
  transparentBackground = true;
  termColors = true;

  highlightOverrides = {
    all = ''
      function(colors)
        return {
          StatusLine = { bg = colors.mantle },
          StatusLineNC = { bg = colors.crust },
        }
      end
    '';
  };
};
```

#### 5.3 文件类型检测迁移

```nix
extraConfigLua = ''
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
'';
```

### 步骤 6：LSP 配置迁移

nixvim 提供内置的 LSP 配置支持：

```nix
plugins.lsp = {
  enable = true;

  servers = {
    # Nix
    nil-ls = {
      enable = true;
      settings = {
        nil = {
          formatting = {
            command = [ "nixfmt" ];
          };
        };
      };
    };

    # Rust
    rust-analyzer = {
      enable = true;
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = true;
          cargo = {
            loadOutDirsFromCheck = true;
          };
          procMacro = {
            enable = true;
          };
          check = {
            command = "clippy";
            extraArgs = [ "--" "-D" "warnings" "-W" "clippy::pedantic" "-W" "clippy::nursery" "-W" "rust-2018-idioms" ];
          };
        };
      };
    };

    # Lua
    lua-ls = {
      enable = true;
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT";
          };
          diagnostics = {
            globals = [ "vim" ];
          };
          workspace = {
            library = "vim.api.nvim_get_runtime_file('', true)";
            checkThirdParty = false;
          };
          telemetry = {
            enable = false;
          };
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

    # 其他语言服务器
    bashls.enable = true;
    pylsp.enable = true;
    clangd.enable = true;
    marksman.enable = true;
    # ... 更多服务器
  };

  # 全局键盘映射
  keymaps = {
    silent = true;
    diagnostic = {
      # 诊断导航
      "<leader>e" = "open_float";
      "[d" = "goto_prev";
      "]d" = "goto_next";
      "<leader>q" = "setloclist";
    };

    lspBuf = {
      # 缓冲区映射
      "gD" = "declaration";
      "gd" = "definition";
      "<leader>wa" = "add_workspace_folder";
      "<leader>wr" = "remove_workspace_folder";
      "<leader>wl" = "list_workspace_folders";
      "<leader>f" = "format";
    };
  };

  # 自动格式化
  formatting = {
    formatOnSave = {
      enable = true;
      allowFiletypes = [ "*" ];
    };
  };
};
```

### 步骤 7：环境特定配置

SSH 环境下的剪贴板配置需要条件判断：

```nix
{ config, lib, ... }:

let
  isSSH = config.home.sessionVariables ? SSH_CLIENT;
in
{
  programs.nixvim = lib.mkIf isSSH {
    extraConfigLua = ''
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
    '';
  };
}
```

### 步骤 8：Workman 键盘布局迁移

Workman 键盘布局可以通过 keymap 选项配置：

```nix
options.keymap = "workman-p";

# 或者提供完整的 keymap 配置
extraConfigVim = builtins.readFile ./workman-p.vim;
```

### 步骤 9：Git 集成迁移

Gitmoji 集成配置：

```nix
autoCmd = [
  {
    event = "BufEnter";
    pattern = "COMMIT_EDITMSG";
    callback = ''
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
        vim.keymap.set('n', '<leader>j', call_fzf, opts);
        vim.keymap.set('i', '<C-J>', call_fzf, opts);
      end
    '';
  }
];
```

### 步骤 10：缩写（Abbreviations）迁移

将 `vimrc` 中的缩写迁移：

```nix
extraConfigVim = ''
  " 用户信息缩写
  iabbrev @mail@ lintd23@outlook.com
  iabbrev @gmail@ lifeich0@gmail.com
  iabbrev <expr> @now@ strftime("%F %T %z")

  " 代码竞赛缩写
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
  iabbrev !chk! i=1; while :; do python ./gen.py > c.in && ./force <c.in >c.ans && ./main.cc.exe <c.in >c.out && printf "%s ok\r" $i || break; i=$((i+1)); done
'';
```

## 迁移后的配置结构

```
fool/nvim/
├── default.nix          # 原有的 Nix 模块（可保留或更新）
├── nixvim.nix           # 新的 nixvim 配置模块
├── nixvim-migration.md  # 本迁移文档
├── nvim-config-skills.md # 配置技能文档
├── workman-p.vim        # Workman 键盘布局（保留）
└── legacy/              # 备份的旧配置文件
    ├── init.vim
    ├── init.lua
    ├── vimrc
    └── lsp.lua
```

## 测试计划

### 阶段 1：基础功能测试
- [ ] Neovim 正常启动
- [ ] 插件正确加载
- [ ] 基本键盘映射工作
- [ ] 主题正确应用

### 阶段 2：核心功能测试
- [ ] LSP 功能正常（代码补全、跳转、格式化）
- [ ] UFO 代码折叠正常
- [ ] FZF 文件查找正常
- [ ] Git 集成正常

### 阶段 3：高级功能测试
- [ ] SSH 环境剪贴板配置
- [ ] 代码覆盖率显示
- [ ] 文件类型检测
- [ ] Workman 键盘布局

### 阶段 4：回归测试
- [ ] 所有原有功能正常
- [ ] 性能无明显下降
- [ ] 配置文件加载时间

## 风险与缓解措施

### 风险 1：配置不兼容
- **风险**：nixvim 配置语法与原生配置不完全兼容
- **缓解**：采用混合迁移策略，保留关键 Lua 配置文件

### 风险 2：插件加载顺序问题
- **风险**：插件加载顺序改变导致功能异常
- **缓解**：仔细测试插件依赖，使用 nixvim 的插件依赖管理

### 风险 3：性能问题
- **风险**：nixvim 生成的配置可能影响启动速度
- **缓解**：使用 lazy.nvim 或 packer.nvim 的延迟加载特性

### 风险 4：调试困难
- **风险**：Nix 配置错误难以调试
- **缓解**：逐步迁移，每次只迁移一小部分功能

## 后续优化建议

### 1. 使用延迟加载
```nix
plugins.catppuccin = {
  enable = true;
  lazy = true;
  event = "VeryLazy";
};
```

### 2. 模块化配置
将不同功能的配置拆分为独立模块：
- `lsp.nix`: LSP 配置
- `ui.nix`: 界面和主题配置
- `keys.nix`: 键盘映射配置
- `tools.nix`: 工具插件配置

### 3. 条件配置
根据环境变量或系统类型配置不同的插件和设置：

```nix
{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  hasGUI = config.services.xserver.enable;
in
{
  programs.nixvim.plugins = {
    # 仅在 GUI 环境下启用某些插件
    neovim-qt.enable = hasGUI;

    # 平台特定插件
    vim-mac.enable = isDarwin;
  };
}
```

### 4. 性能监控
监控启动时间和内存使用：
- 使用 `vim-startuptime` 插件
- 定期优化配置
- 移除不必要的插件

## 结论

迁移到 nixvim 可以提供以下好处：

1. **声明式配置**：所有配置在 Nix 中管理，易于复制和版本控制
2. **更好的集成**：与 Nix 生态系统深度集成
3. **模块化**：可重用的配置模块
4. **类型安全**：Nix 的类型检查减少配置错误

建议按照以下时间线进行迁移：
- **第 1 周**：创建基础 nixvim 配置，迁移插件和基本设置
- **第 2 周**：迁移 LSP 配置和键盘映射
- **第 3 周**：迁移高级功能和环境特定配置
- **第 4 周**：全面测试和优化

通过逐步迁移和充分测试，可以确保在享受 nixvim 优势的同时，保持现有工作流的稳定性。

## 参考资料

1. [nixvim 官方文档](https://github.com/nix-community/nixvim)
2. [Neovim 配置指南](https://github.com/neovim/neovim/wiki)
3. [Nix 语言教程](https://nixos.org/guides/nix-language)
4. [Home Manager 文档](https://nix-community.github.io/home-manager/)

---

*最后更新：2026-03-29*
*作者：AI 助手*
*状态：草案*

