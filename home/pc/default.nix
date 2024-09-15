{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # trials on one host
    charasay
  ];

  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  fool.misc.gtr = true;

  fool.cargo.ctrl-config = true;
  fool.gpg.pinentry = pkgs.pinentry-qt;
  fool.proxy.use-pi = true;
  fool.git.github-proxy = true;
  fool.zsh = {
    enable = true;
    with-skim = true;
  };
  fool.cfg-ssh = {
    vultr = true;
    qcraft = true;
  };
  fool.nvim.lsp = true;
  fool.alacritty = {
    enable = true;
    font-size = 10;
  };
  fool.attic.watch-store = true;

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-rime
      fcitx5-lua
    ];
  };
}
