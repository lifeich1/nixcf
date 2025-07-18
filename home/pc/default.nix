{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # trials on one host
    charasay
  ];

  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  fool.bililiverecorder.enable = true;

  fool.misc.gtr = true;

  fool.cargo.ctrl-config = true;
  fool.cp-guard.enable = true;
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
    soc = true;
  };
  fool.nvim = {
    lsp = true;
    nightly = false;
  };
  fool.alacritty = {
    enable = true;
    font-size = 10;
  };
  fool.kitty = {
    enable = true;
    font-size = 12;
  };
  fool.attic.watch-store = true;
}
