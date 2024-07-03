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
      aria
      qbittorrent

      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      ripgrep # recursively searches directories for a regex pattern
      #jq # A lightweight and flexible command-line JSON processor
      #yq-go # yaml processer https://github.com/mikefarah/yq
      eza # A modern replacement for ‘ls’
      #fzf # A command-line fuzzy finder
      skim
      just

      # networking tools
      #mtr # A network diagnostic tool
      #iperf3
      dnsutils # `dig` + `nslookup`
      #ldns # replacement of `dig`, it provide the command `drill`
      #aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      #ipcalc  # it is a calculator for the IPv4/v6 addresses

      # misc
      #cowsay
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      #gnupg
      #busybox
      psmisc

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      #nix-output-monitor
      colmena
      nh

      # productivity
      #hugo # static site generator
      #glow # markdown previewer in terminal

      btop # replacement of htop/nmon
      #iotop # io monitoring
      #iftop # network monitoring

      # system call monitoring
      #strace # system call monitoring
      #ltrace # library call monitoring
      lsof # list open files

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb

      # TODO put into programs/
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
      attic-client

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

  programs.helix.enable = true;
  programs.emacs.enable = true;

  fool.gpg.pinentry = pkgs.pinentry-qt;
  fool.proxy.use-pi = true;
  fool.git = {
    # TODO proxy enabled directories
  };
  fool.zsh.enable = true;
  fool.cfg-ssh = {
    vultr = true;
    qcraft = true;
  };
  fool.nvim.lsp = true;
  fool.alacritty = {
    enable = true;
    font-size = 10;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-rime
      fcitx5-lua
    ];
  };

  ## TODO pack as mod in future
  # dep: attic-client
  systemd.user.services."attic-watch-store" = {
    Unit = {
      Description = "Watch the Nix Store for new paths and upload them to a binary cache";
      After = [ "basic.target" ];
      Wants = [ "basic.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.attic-client}/bin/attic watch-store my-pi_attic";
    };
  };
  xdg.configFile."attic/config.toml".source = ./attic-client.toml;
}
