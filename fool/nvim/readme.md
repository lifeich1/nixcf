# Neovim

`default.nix` 是当前 Neovim/Home Manager 配置入口，基础编辑器默认启用，并通过 Nixvim 生成 wrapper、插件和 init 配置。

- `base.nix`：基础插件、provider、Workman keymap runtime 文件，以及从旧 `vimrc`/`init.lua` 迁入的基础配置。
- `lsp.nix`：LSP 工具、插件、treesitter grammar 和 `lsp.lua` 配置，仅在 `fool.nvim.lsp` 开启时生效。
- `ai.nix`：AI 插件，仅在 `fool.nvim.ai` 开启时生效；当前只安装 `avante-nvim`，不执行 setup。
- `vimrc`、`init.vim`、`init.lua`、`lsp.lua`：迁移期兼容源文件，后续阶段继续拆分/删除。
- `workman-p.vim`：自定义键位文件，通过 Nixvim runtime 文件加载。
- `nixvim-migration.md`：迁移记录；`nvim-config-skills.md`：本目录维护提示。
- `fool.nvim.lsp` 默认关闭，在桌面公共配置中开启；`fool.nvim.ai` 默认关闭，仅 `home/pc` 开启。
