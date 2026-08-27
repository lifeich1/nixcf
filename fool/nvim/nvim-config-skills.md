# Neovim 配置技能总结

基于 `fool/nvim/` 目录的配置分析

## 概述

这是一个使用 Nixvim 管理的现代化 Neovim 配置，支持多种编程语言和开发工具。配置采用模块化设计，基础行为已迁入 `base.nix`，LSP 仍在迁移期保留少量 Lua 兼容配置。

## 配置文件结构

```
fool/nvim/
├── base.nix          # Nixvim 基础插件和兼容配置
├── lsp.nix           # LSP 插件、工具和 Lua 配置
├── ai.nix            # AI 插件
├── init.vim          # 旧主配置文件，待删除
├── init.lua          # 旧 Lua 基础配置，已迁入 base.nix，待删除
├── vimrc             # 旧 Vim 基础配置，已迁入 base.nix，待删除
├── workman-p.vim     # Workman 键盘布局映射
├── lsp.lua           # LSP 兼容配置，待迁入 lsp.nix
└── default.nix       # Nix 模块配置
```

## 核心功能

### 1. 插件管理
- **插件管理器**: Nixvim 管理插件闭包，minpac 仅保留为可选兼容命令
- **Nix 集成**: 通过 Nix 包管理器安装和管理插件
- **可选插件**: 支持按需加载插件
- **主要插件**:
  - catppuccin-nvim (主题)
  - nvim-ufo (代码折叠)
  - nvim-lspconfig (LSP 配置)
  - nvim-treesitter (语法高亮)
  - fzf-vim (模糊查找)
  - vim-fugitive (Git 集成)
  - nvim-coverage (代码覆盖率)

### 2. 语言服务器协议 (LSP)
- **支持的语言服务器**:
  - Rust: rust-analyzer
  - Nix: nil + nixfmt
  - Lua: lua-language-server
  - Python: python-lsp-server
  - C/C++: ccls/clangd
  - Bash: bash-language-server
  - Perl: PLS
  - Markdown: marksman
  - Web: vscode-langservers-extracted

- **LSP 功能**:
  - 自动补全
  - 代码格式化
  - 错误检查
  - 代码导航
  - 悬停文档
  - 重命名重构

### 3. 代码折叠 (UFO)
- 支持高级代码折叠
- 折叠预览窗口
- 快捷键:
  - `zR`: 打开所有折叠
  - `zM`: 关闭所有折叠
  - `zr`: 打开除特定类型外的折叠
  - `zm`: 关闭特定类型的折叠
  - `K`: 预览折叠内容或显示悬停文档

### 4. 主题和外观
- **主题**: Catppuccin (frappe 风格)
- **透明背景**: 支持透明终端背景
- **状态栏定制**: 自定义状态栏颜色
- **语法高亮**: Tree-sitter 提供精确的语法高亮

### 5. 键盘映射和快捷键

#### 领导键 (Leader)
- `<leader>` = 空格键
- `<localleader>` = `\`

#### 常用快捷键
- **窗口管理**:
  - `<M-h/j/k/l>`: 窗口间导航
  - `<M-->`: 切换到前一个标签页
  - `<M-=>`: 切换到下一个标签页

- **文件操作**:
  - `<F2>`: 保存文件

- **搜索和导航**:
  - `<leader>o`: 文件搜索 (fzf)
  - `<leader>zb`: 缓冲区列表
  - `<leader>zw`: 窗口列表
  - `<leader>gg`: Grepper 搜索

- **LSP 相关**:
  - `gD`: 转到声明
  - `gd`: 转到定义
  - `<leader>e`: 打开诊断浮窗
  - `[d`/`]d`: 导航诊断
  - `<leader>f`: 格式化代码

#### Workman 键盘布局
- 支持 Workman-P 键盘布局
- 通过 `set keymap=workman-p` 启用
- 快捷键: `<leader>kj` 启用, `<leader>kk` 禁用

### 6. 文件类型支持
- **自定义文件类型**:
  - `.lalrpop`: LALR 解析器生成器
  - `.json.age`: 加密的 JSON 文件
  - `.pb.txt`: Protocol Buffers 文本格式

- **Tree-sitter 支持**:
  - lalrpop
  - just
  - toml
  - textproto

### 7. Git 集成
- **vim-fugitive**: Git 命令集成
- **Git commit emoji**: 提交时选择 emoji (`<leader>j` 或 `<C-J>`)
- **变更状态**: 集成到状态栏

### 8. 特殊功能

#### SSH 环境支持
- 在 SSH 会话中自动使用 OSC52 剪贴板
- 通过 lemonade 工具实现远程剪贴板共享

#### 代码覆盖率
- 支持 Rust 代码覆盖率
- 使用 cargo-llvm-cov 生成覆盖率报告
- 可视化显示覆盖/未覆盖的代码行

#### 自动补全
- 模糊匹配补全
- 自动触发补全（在 `.` 和 `>` 字符后）
- 快捷键: `<C-M-i>` 手动触发补全

#### 代码格式化
- 保存时自动格式化
- 支持多种格式化工具:
  - nixfmt (Nix)
  - rustfmt (Rust)
  - Lua 格式化器
  - 其他语言的 LSP 格式化

### 9. 配置选项

通过 Nix 配置模块提供选项：

```nix
{
  fool.nvim = {
    lsp = true;      # 启用 LSP
    ai = false;      # 启用 AI 助手
  };
}
```

## 依赖工具

- **必需工具**:
  - fzf (模糊查找)
  - fd (文件查找)
  - lemonade (远程剪贴板)
  - neovim-remote
  - gitmoji-cli

- **LSP 工具** (可选):
  - nil (Nix LSP)
  - rust-analyzer
  - lua-language-server
  - 各种语言服务器

## 配置特点

1. **模块化设计**: 通过 Nix 模块实现配置的模块化
2. **环境感知**: 自动检测 SSH 环境并调整配置
3. **性能优化**: 延迟加载可选插件
4. **跨平台**: 支持本地和远程开发环境
5. **可扩展**: 易于添加新的语言支持和插件

## 使用技巧

1. **代码导航**: 结合 fzf 和 LSP 实现快速导航
2. **代码审查**: 使用覆盖率工具检查测试覆盖
3. **远程开发**: SSH 环境下的剪贴板无缝工作
4. **多语言开发**: 支持多种编程语言的现代化开发体验

这个配置为开发者提供了完整的现代化编辑器体验，结合了 Vim 的高效性和现代 IDE 的功能。
