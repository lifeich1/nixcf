{ pkgs, ... }@all:

{
  # 通过 home.packages 安装一些常用的软件
  # 这些软件将仅在当前用户下可用，不会影响系统级别的配置
  # 建议将所有 GUI 软件，以及与 OS 关系不大的 CLI 软件，都通过 home.packages 安装
  home.packages =
    with pkgs;
    [
      vlc
      # web
      qbittorrent

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      nix-output-monitor
      colmena
      nvd

      # productivity
      #hugo # static site generator
      #glow # markdown previewer in terminal

      # TODO put into programs/
      wpsoffice-cn
      google-chrome
      syncthingtray
      tor-browser
      calibre
      yt-dlp
      lux
      jekyll
      python3
      appimage-run
      usbimager
      rpi-imager
      emojify
      guitarix
      nixpkgs-review
      nix-du
      graphviz

      # KDE
      krita
      libsForQt5.kdenlive
      glaxnimate # dep by kdenlive
      libsForQt5.plasma-integration
      libsForQt5.plasma-browser-integration
      libsForQt5.ktimer
      libsForQt5.kdeplasma-addons
    ]
    ++ [ all.inputs.agenix.packages."${all.system}".default ];

  programs.helix.enable = true; # NOTICE learning
  programs.emacs.enable = true; # TODO pack configs

  fool.cargo.ctrl-config = true;
  fool.gpg.pinentry = pkgs.pinentry-qt;
  fool.proxy.use-pi = true;
  fool.git = {
    # TODO proxy enabled directories
  };
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
