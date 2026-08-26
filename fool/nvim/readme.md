# Neovim

`default.nix` 是当前 Neovim/Home Manager 配置入口，基础编辑器默认启用，并用 `lsp`、`ai`、`nightly` 控制附加能力。

- `vimrc`、`init.vim`、`init.lua`：兼容层与主配置入口。
- `lsp.lua`：LSP 配置，仅在 `fool.nvim.lsp` 开启时部署。
- `workman-p.vim`：自定义键位文件。
- `nixvim-migration.md`：迁移记录；`nvim-config-skills.md`：本目录维护提示。
- 根目录 `just nvim` 可把配置复制/硬链式开发到用户目录，操作前注意现有备份文件。
