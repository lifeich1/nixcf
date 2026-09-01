---
name: commit-message
description: Compose commit messages following the Gitmoji convention (<emoji> <component> - <desc>, imperative, ≤50 chars, optional body). Use when preparing any commit message.
---

# Commit Message 技能总结

基于 nixcf 仓库 483 条 commit 历史分析。

## 核心模式

每条 commit 消息以 **gitmoji** 开头，后接空格 + 简洁英文描述（首字母小写，无句号）。

```
:sparkles: enable currently simple ok lsp
:bug: fix commit in nvim term
:recycle: split zsh conf
```

## Gitmoji 语义映射

| Gitmoji | 含义 | 典型场景 |
|---|---|---|
| `:arrow_up:` | 依赖升级 | lock update, 软件版本升级 |
| `:wrench:` | 配置调整 | ssh config, nvim 微调 |
| `:sparkles:` | 新功能引入 | 添加新模块/工具/功能 |
| `:bug:` | Bug 修复 | 修复具体问题 |
| `:heavy_plus_sign:` | 添加依赖/包 | 向环境添加新包 |
| `:recycle:` | 重构 | 拆分配置、模块化 |
| `:construction:` | WIP | 未完成的移植或开发 |
| `:alembic:` | 实验 | 尝试新方案、调试 |
| `:coffin:` | 移除死代码 | 删除无用旧配置 |
| `:fire:` | 移除代码 | 减少引用、清理 |
| `:ambulance:` | 紧急修复 | 严重 bug 的 hotfix |
| `:pencil2:` | 修正拼写/typo | fix typos, lint |
| `:art:` | 代码格式化 | better fmt、风格改进 |
| `:boom:` | 破坏性变更 | 重大结构变更 |
| `:truck:` | 移动/重命名 | 模块拆分、目录移动 |
| `:rocket:` | 部署相关 | 部署脚本、VM 发布 |
| `:lipstick:` | UI/外观微调 | 字体、图标修复 |
| `:rotating_light:` | 修复 lint 警告 | fix deprecated, collision |
| `:rewind:` | 回退变更 | revert 某个改动 |
| `:memo:` | 文档 | 添加文档/注释/笔记 |
| `:white_check_mark:` | 测试通过 | 验证某项功能 |
| `:green_heart:` | 修复 CI | fix vm build |
| `:bookmark:` | 打标签/里程碑 | vm proxy point |
| `:alien:` | API 适配 | 适配上游 API 变更 |
| `:see_no_evil:` | .gitignore | 更新 ignore file |
| `:pushpin:` | 固定版本 | flake.lock 相关 |
| `:zap:` | 性能优化 | 启动速度、ssh 连接 |
| `:children_crossing:` | UX 改进 | 输入法切换优化 |
| `:technologist:` | 开发者体验 | dev config, 调优 dev experience |
| `:wheelchair:` | 可访问性 | 别名辅助 |
| `:heavy_minus_sign:` | 移除依赖 | disable 某 substituter |
| `:arrow_down:` | 降级依赖 | rustdesk 降级 |
| `:test_tube:` | 测试实验 | nix-daemon proxy test |
| `:bulb:` | 添加注释 | 代码中的文档注释 |
| `:card_file_box:` | 数据库相关 | 数据源变更 |
| `:bento:` | 资产添加 | SSH keys、图片等资产 |
| `:package:` | 打包相关 | nix p10k |
| `:building_construction:` | 架构变更 | 替换核心工具(rustdesk -> teamviewer) |
| `:hammer:` | 工具/脚本改进 | 脚本重构、工具链 |
| `:heavy_minus_sign:` | 移除依赖 | 禁用/删除某个依赖 |

## 复合 emoji

一次 commit 涉及多个维度时，使用多个 gitmoji 连接：

```
:hammer: :bug: fix switch to test branch       # 工具改进 + 修 bug
:coffin: :zap: shred flake.lock                 # 清理 + 性能
:sparkles: :construction: zellij & wip colmena  # 新功能 + WIP
:coffin: :memo: rm unused cfg & add todo        # 清理 + 文档
:wrench: :children_crossing: add input mozc     # 配置 + UX
:rotating_light: :alien: use zsh.initContent    # lint + API 适配
```

## 描述结构

### 格式

- 使用**祈使句**（fix/add/remove/split，而非 fixed/added）
- 描述主体**小写开头**，无结尾标点
- 尽量不超过 **50 字符**

### 范围标注（scope）

用冒号分隔 scope 和具体内容：

```
:wrench: cfg-ssh: soc                    # 模块: 具体内容
:wrench: gtr7: hashedPasswordFile
:wrench: pc: enable sshcfg soc
:recycle: nvim: nix manager all plugins
:bug: nvim_cfg: fix TS, replace errwln
:wrench: kitty: silent bell
:wrench: :recycle: wezterm cfg lua
```

### 简写/缩写

- **设备名**：gtr5/gtr7、xps13、combk、pi、opi、hw-p60
- **技术名**：p10k、vm、ssh、nvim/cfg、lsp、TS、hm、kde、NUR
- **动作动词**：rm、fix、try、use、enable、split、port、tune、tweak

## 正文（body）用法

复杂 commit 使用空行分隔描述和正文，正文通常用列表：

```
:construction: porting nvim configs
TODO:
- p10k by nix
- gtr5 only env make it conditional
- nixos only ZSH_CUSTOM
```

## 特殊 commit 类型

- **Merge commit**：`Merge branch 'xps13'` / `Merge remote-tracking branch 'origin/main' into nix-gc`
- **Revert commit**：`Revert ":arrow_up: lock update"`（保留原 commit 标题引用）
  - 当 revert 后再次应用同内容：`:rewind: active ttf-ms-win10 for welcome font bug`
  - 或说明原因：`Revert lock update for pkgs linux-lqx broken`
- **Initial commit**：`Initial commit`（无 emoji）

## 最佳实践总结

1. **约定优于配置** — 全仓库统一 gitmoji，视觉扫描效率极高
2. **一个 commit 一个关注点** — 避免混合不同目的的变更
3. **描述 what 隐含 why** — "fix commit in nvim term" 即说明了 what（修了 nvim terminal 里的 commit），也暗示了 why（之前在那环境里 commit 有问题）
4. **善用缩写和领域术语** — 对熟悉项目的开发者来说，`p10k`、`colmena`、`nvim` 比全称更高效
5. **保持一致性** — 从项目建立至今 483 条 commit，风格高度一致
6. **工具辅助** — 项目中使用了 `fzf gitmoji` 交互式选择，可考虑结合 `gitmoji-cli` 或自定义 commit template 固化习惯

## 常用句式参考

```
:sparkles: add <feature>
:sparkles: intro <feature>
:sparkles: enable <feature>
:bug: fix <problem>
:bug: try fix <problem>                # 不确定是否能修好
:wrench: <component>: <change>
:recycle: split <component>
:recycle: <component>: <refactor>
:recycle: <action> <component> -> <result>
:arrow_up: lock update
:arrow_up: <package> <version>
:coffin: rm <dead_code>
:coffin: unused <thing>
:fire: <remove_what>
:heavy_plus_sign: <package>
:alembic: try <experiment>
:construction: porting <component>
:boom: <breaking change>
:truck: <from> -> <to>
:art: <fmt/restructure>
:memo: <note/doc>
:rotating_light: fix <lint/deprecated>
:ambulance: <critical fix>
:children_crossing: <ux improvement>
:technologist: <dev exp improvement>
:lipstick: <cosmetic/font/icon fix>
```

