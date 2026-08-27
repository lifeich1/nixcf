{ pkgs, ... }:

{
  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  fool.cargo.ctrl-config = true;
  fool.desktop.apps.enable = true;
  fool.desktop.programs.enable = true;
  fool.misc.nixbuild = true;
  fool.com-lemonade.enable = true;
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
  fool.nvim.lsp = true;
  fool.alacritty.enable = true;
}
