{ pkgs, ... }:

{
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
}
