{
  config,
  lib,
  hmConfig,
  ...
}:
lib.mkIf hmConfig.fool.nvim.markdown {
  plugins.render-markdown = {
    enable = true;
    # 取插件 wiki 的 "Useful Configuration Options"（与 nixvim 上游 settingsExample 一致）；
    # render_modes 在新版已废弃，故意不设。
    settings = {
      signs.enabled = false;
      bullet = {
        icons = [
          "◆ "
          "• "
          "• "
        ];
        right_pad = 1;
      };
      # WezTerm 背景半透明（opacity 0.85）：尽量只用前景色/图标，不铺底色。
      heading = {
        sign = true;
        position = "inline";
        # “背景”高亮直接指到同级标题前景组（H1..H6），保留层级配色但不再铺底色；
        # 默认的 RenderMarkdownH*Bg 会链到 DiffText 等带背景的组。
        backgrounds = [
          "RenderMarkdownH1"
          "RenderMarkdownH2"
          "RenderMarkdownH3"
          "RenderMarkdownH4"
          "RenderMarkdownH5"
          "RenderMarkdownH6"
        ];
        icons = [
          "1 "
          "2 "
          "3 "
          "4 "
          "5 "
          "6 "
        ];
      };
      code = {
        sign = true;
        width = "block";
        position = "right";
        language_pad = 2;
        # 代码块本体不铺底色；border 与语言行的默认高亮都从 ColorColumn 派生，
        # 会画出整行色块，这里一并关闭。语言名仍用 @label 前景色显示。
        border = "none";
        disable_background = true;
        highlight_border = false;
        # inline code 用 Treesitter 的 @markup.raw 前景色替代默认 CodeInline 底色。
        highlight_inline = "@markup.raw";
      };
    };
  };

  # render-markdown 依赖 markdown/markdown_inline 解析器。treesitter 本体由 lsp.nix
  # 提供，这里用 mkDefault / 各自声明 grammarPackages，使本开关单独打开时也自洽；
  # 两个模块的列表会合并为并集。
  plugins.treesitter = {
    enable = lib.mkDefault true;
    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      markdown
      markdown_inline
    ];
  };
}
