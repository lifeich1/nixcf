# Neovim

`default.nix` 是当前 Neovim/Home Manager 配置入口，基础编辑器默认启用，并通过 Nixvim 生成 wrapper、插件和 init 配置。

- `base.nix`：基础插件、provider、Workman keymap runtime 文件、基础选项、普通键位、autocmd、Catppuccin/UFO/coverage 配置，以及少量保留的 Vimscript/Lua 兼容片段。
- `lsp.nix`：LSP server、LspAttach 行为、diagnostic 键位、`fzf-lsp-nvim` 和四个 treesitter grammar，仅在 `fool.nvim.lsp` 开启时生效。
- `ai.nix`：AI 插件，仅在 `fool.nvim.ai` 开启时生效；当前只安装 `avante-nvim`，不执行 setup。
- `vimrc`、`init.vim`、`init.lua`：旧配置源文件，基础配置已迁入 `base.nix`，后续阶段删除。
- `lsp.lua`：旧 LSP 源文件，配置已迁入 `lsp.nix`，后续阶段删除。
- `workman-p.vim`：自定义键位文件，通过 Nixvim runtime 文件加载。
- `nixvim-migration.md`：迁移记录；`nvim-config-skills.md`：本目录维护提示。
- `fool.nvim.lsp` 默认关闭，在桌面公共配置中开启；`fool.nvim.ai` 默认关闭，仅 `home/pc` 开启。
