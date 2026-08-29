# Neovim

`default.nix` 是当前 Neovim/Home Manager 配置入口，基础编辑器默认启用，并通过 Nixvim 生成 wrapper、插件和 init 配置。

## 模块边界

- `default.nix`：声明 `fool.nvim.lsp`、`fool.nvim.ai`，启用 `programs.nixvim`，显式复用 flake 的主 nixpkgs，并保留 Neovim 外围 CLI 与 LSP 工具包。
- `base.nix`：基础插件、provider、Workman keymap runtime 文件、基础选项、普通键位、autocmd、Catppuccin/UFO/coverage 配置，以及少量仍需原样保留的 Vimscript/Lua 兼容片段。
- `lsp.nix`：LSP server、LspAttach 行为、diagnostic 键位、`fzf-lsp-nvim` 和四个 Treesitter grammar，仅在 `fool.nvim.lsp` 开启时生效。
- `ai.nix`：AI 插件，仅在 `fool.nvim.ai` 开启时生效；当前只安装 `avante-nvim`，不执行 setup。
- `workman-p.vim`：自定义键位文件，通过 Nixvim runtime 文件加载。
- `nvim-config-skills.md`：本目录维护提示。

## 公开开关

- `fool.nvim.lsp` 默认关闭，在桌面公共配置中开启；GTR7、XPS13 启用，Pi4B 关闭。
- `fool.nvim.ai` 默认关闭，仅 `home/pc` 开启。

## 验证

- Nix 配置改动优先运行 `just chk`。
- 定向验证 Nixvim wrapper 可运行 `just nvim`，默认构建并启动 `nixos-gtr7` 的 Nixvim wrapper；其他主机可用 `just nvim nixos-xps13` 或 `just nvim nixos-pi4b`。
