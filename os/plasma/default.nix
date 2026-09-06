{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.plasma;
in
{
  options.fool.plasma = {
    enable = mkEnableOption "plasma desktop";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    services.xserver.xkb = {
      layout = "cn";
      variant = "";
    };

    # KDE Connect：上游 programs.kdeconnect 在 enable 时自动开放 TCP/UDP 1714-1764
    # （无需额外 option，求值验证见 refactor-plan-04 阶段 2）。规则单一所有者 =
    # 上游 kdeconnect module，随 plasma/desktop profile（fool.plasma.enable）启用；
    # 不在 host/通用 firewall 重复写端口。
    programs.kdeconnect.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          qt6Packages.fcitx5-chinese-addons
          fcitx5-mozc
          fcitx5-rime
        ];
      };
    };

    environment.systemPackages =
      # sometimes curl causes problem, try switch to hotpot
      # https://discourse.nixos.org/t/nixos-install-returns-unable-to-download-cache-nixos-org/65488/4
      (with pkgs.nur.repos.rewine; [
        ttf-wps-fonts # for wps
        ttf-ms-win10 # WARN: collision with ttf-wps-fonts
      ])
      ++ (with pkgs; [
        sarasa-gothic # 更纱黑体
      ]);

    # FIX calibre ebook-viewer env, see also https://discussion.fedoraproject.org/t/calibre-and-wayland/100384/3
    nixpkgs.overlays = [
      (_: prev: {
        calibre =
          pkgs.runCommand "calibre-wayland"
            {
              buildInputs = [ prev.calibre ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
            }
            ''
              mkdir -p $out/bin/
              ln -s ${prev.calibre}/bin/calibre $out/bin/calibre
              wrapProgram $out/bin/calibre --prefix QT_QPA_PLATFORM : xcb
              ln -s ${prev.calibre}/share $out/share
            '';
      })
    ];
  };
}
