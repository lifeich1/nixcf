# Neovim

`default.nix` 是当前 Neovim/Home Manager 配置入口，基础编辑器默认启用，并通过 Nixvim 生成 wrapper、插件和 init 配置。

## 模块边界

- `default.nix`：声明 `fool.nvim.lsp`，启用 `programs.nixvim`，显式复用 flake 的主 nixpkgs，并保留 Neovim 外围 CLI 与 LSP 工具包。
- `base.nix`：聚合 `plugins.nix`、`editor.nix`、`keymaps.nix`、`workflow.nix` 四个行为分片（在同一 module 内 `mkMerge`，保持 Nixvim `types.lines` 的合并顺序）。
- `plugins.nix`：基础插件及其 setup（Catppuccin、UFO、coverage 等）。
- `editor.nix`：编辑选项、autocmd 与 provider。
- `keymaps.nix`：普通键位与 Workman runtime 接入。
- `workflow.nix`：gitmoji、竞赛缩写、remote clipboard 等个人工作流。
- `lsp.nix`：LSP server、LspAttach 行为、diagnostic 键位、`fzf-lsp-nvim` 和 Treesitter grammar，仅在 `fool.nvim.lsp` 开启时生效。
- `workman-p.vim`：自定义键位文件，通过 Nixvim runtime 文件加载。
- `nvim-config-skills.md`：本目录维护提示。

## 公开开关

- `fool.nvim.lsp` 默认关闭，在桌面公共配置中开启；GTR7、XPS13 启用，Pi4B 关闭。
- 原 `fool.nvim.ai`（Avante）已删除：未完成 provider/secret 接入，不保留“启用但不可用”的开关
  （refactor-plan-05 阶段 7）。如需 AI 功能，应另立计划补齐 provider、runtime secret 与健康检查。

## 验证

- Nix 配置改动优先运行 `just chk`。
- 定向验证 Nixvim wrapper 可运行 `just nvim`，默认构建并启动 `nixos-gtr7` 的 Nixvim wrapper；其他主机可用 `just nvim nixos-xps13` 或 `just nvim nixos-pi4b`。
