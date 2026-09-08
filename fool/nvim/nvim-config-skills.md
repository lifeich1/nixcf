# nvim 模块（Nixvim 配置维护提示）

> 本 skill 用于修改 `fool/nvim/` 时保持一致结构：不要在 base 级重复插件/
> 键位所有权；拆分文件时保持生成的 Lua 不变（`lib.mkMerge` 顺序敏感）。

## 配置文件结构

```text
fool/nvim/
├── default.nix       # fool.nvim.lsp option、外围包、programs.nixvim 入口
├── base.nix          # 聚合入口：mkMerge 组合 plugins/editor/keymaps/workflow
├── plugins.nix       # extraPlugins、plugins.coverage/nvim-ufo、colorschemes
├── editor.nix        # globals、opts、autoGroups/autoCmd（py 缩进）
├── keymaps.nix       # keymaps 列表、files."keymap/workman-p.vim"
├── workflow.nix      # GitEmoji autocmd、extraConfigVim、extraConfigLuaPost
├── lsp.nix           # LSP server、attach 行为、diagnostic、treesitter
├── workman-p.vim     # Workman 键盘布局映射
├── readme.md
└── nvim-config-skills.md
```

## 模块职责

- `default.nix`：
  - 声明 `fool.nvim.lsp` option。
  - 启用 `programs.nixvim`、alias、provider、`impureRtp = false` 和 `enablePrintInit = true`。
  - 维护 `home.packages` 中的 Neovim 外围 CLI（fzf、fd、lemonade、neovim-remote、gitmoji-cli、nixfmt）。
- `base.nix`（聚合入口）：
  - 通过 `lib.mkMerge` 组合以下四个子模块。
- `plugins.nix`：
  - 声明 `extraPlugins` 列表与 `plugins.coverage`、`plugins.nvim-ufo`、`colorschemes.catppuccin`。
- `editor.nix`：
  - 声明 `globals`、`opts`、`autoGroups.py_iden`、`autoCmd`（py 缩进）。
- `keymaps.nix`：
  - 声明整体 `keymaps` 列表与 `files."keymap/workman-p.vim"`。
- `workflow.nix`：
  - 声明 `autoGroups.GitEmoji`、`autoCmd`（gitmoji 回调）、`extraConfigVim`（iabbrev、FZF、provider 路径、竞赛缩写、cnoremap）、`extraConfigLuaPost`（filetype.add、clipboard、addon 加载）。
- `lsp.nix`：
  - 只在 `hmConfig.fool.nvim.lsp` 为真时启用。
  - 声明 `jsonls`、`html`、`cssls`、`pylsp`、`bashls`、`clangd`、`eslint`、`vimls`、`marksman`、`perlpls`、`nil_ls`、`rust_analyzer`、`lua_ls`。
  - 每个 server 的 `enable = true`，`package` 由 nixvim server module 默认提供（来自 `packages.nix` 映射），不再单设 `package = null`。
  - 限定 Treesitter grammar 为 `lalrpop`、`just`、`toml`、`textproto`。

## 公开开关

- `fool.nvim.lsp`：启用 LSP server 与 Treesitter（仅桌面 profile 启用）。