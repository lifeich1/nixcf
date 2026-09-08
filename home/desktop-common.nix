{ pkgs, ... }:

{
  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  # cargo mirror (thin desktop-only config, inlined per plan 05 step 2)
  home.file.".cargo/config.toml".text = ''
    [source.crates-io]
    replace-with = 'mirror'

    [source.mirror]
    registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
  '';
  fool.desktop.apps.enable = true;
  fool.desktop.programs.enable = true;
  fool.misc.nixbuild = true;
  fool.com-lemonade.enable = true;
  fool.reasonix.enable = true;
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
  fool.fastfetch.enable = true;
}
