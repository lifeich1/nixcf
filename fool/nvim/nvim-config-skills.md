# Neovim 配置维护提示

## 概述

本目录使用 Nixvim 管理 Neovim wrapper、插件闭包和最终 init 配置。Home Manager 仍负责外围 CLI 包和主机级开关。

## 配置文件结构

```text
fool/nvim/
├── default.nix       # fool.nvim options、外围包、programs.nixvim 入口
├── base.nix          # 基础插件、选项、键位、autocmd 和兼容片段
├── lsp.nix           # LSP server、attach 行为、diagnostic、treesitter
├── ai.nix            # AI 插件条件安装
├── workman-p.vim     # Workman 键盘布局映射
├── readme.md
└── nvim-config-skills.md
```

## 模块职责

- `default.nix`：
  - 声明 `fool.nvim.lsp` 和 `fool.nvim.ai`。
  - 启用 `programs.nixvim`、alias、provider、`impureRtp = false` 和 `enablePrintInit = true`。
  - 维护 `home.packages` 中的 Neovim 外围 CLI 与 LSP 工具。
- `base.nix`：
  - 声明基础插件、主题、UFO、coverage、全局变量、选项、键位、autocmd。
  - 用 `files."keymap/workman-p.vim"` 安装 Workman keymap。
  - 保留 minpac 命令、abbreviation、本地 provider 探测、SSH clipboard 和 `~/.lintd/nvim/addon.lua` 加载等兼容片段。
- `lsp.nix`：
  - 只在 `hmConfig.fool.nvim.lsp` 为真时启用。
  - 声明 `jsonls`、`html`、`cssls`、`pylsp`、`bashls`、`clangd`、`eslint`、`vimls`、`marksman`、`perlpls`、`nil_ls`、`rust_analyzer`、`lua_ls`。
  - 所有 server 使用 `package = null`，工具包仍由 Home Manager 显式安装。
  - 限定 Treesitter grammar 为 `lalrpop`、`just`、`toml`、`textproto`。
- `ai.nix`：
  - 只在 `hmConfig.fool.nvim.ai` 为真时安装 `avante-nvim`。
  - 当前不调用 setup，不声明 provider 或密钥。

## 公开开关

通过 Nix 配置模块提供选项：

```nix
{
  fool.nvim = {
    lsp = true;      # 启用 LSP
    ai = false;      # 启用 AI 助手
  };
}
```

## 维护规则

- 不恢复 Home Manager 旧 Neovim module 或旧的用户目录配置复制流程。
- 不新增 nightly 空壳开关；如需 nightly，必须先添加真实 flake input 并单独验证。
- 不把 API key、token 或本地 addon 内容写入 Nix store 或 Git。
- 新增插件或语言能力时，优先在 Nixvim module 中声明；只有 Nixvim 当前无法等价表达时才使用小段 raw Vimscript/Lua。
- 修改本目录 Nix 配置后优先运行 `just chk`；快速检查 wrapper 可运行 `just nvim` 或 `just nvim <host>`。

## 常用行为

- `<leader>` 是空格，`<localleader>` 是 `\`。
- `<leader>o` 打开 fzf 文件搜索，`<leader>gg` 按需加载 Grepper。
- `zR`、`zM`、`zr`、`zm` 控制 UFO 折叠；`K` 优先预览折叠，否则走 LSP hover。
- `fool.nvim.lsp` 开启时，`gD`、`gd`、`<localleader>f`、`<localleader>e`、`[d`、`]d` 等 LSP/diagnostic 键位生效。
- Workman-P 通过 runtime keymap 提供，`<leader>kj` 启用，`<leader>kk` 关闭。
