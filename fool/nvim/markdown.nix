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
      heading = {
        sign = false;
        width = "full";
        position = "inline";
        border = true;
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
        sign = false;
        width = "block";
        position = "right";
        language_pad = 2;
        left_pad = 2;
        right_pad = 2;
        border = "thick";
        above = " ";
        below = " ";
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
