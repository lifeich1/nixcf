{
  config,
  lib,
  pkgs,
  inputs,
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
      # 字体来源单一化（audit §10）：保留 ttf-ms-win10（arial/calibri/微软雅黑/宋体等），
      # 移除与它冲突的 ttf-wps-fonts；WPS 使用系统字体。
      (with pkgs.nur.repos.rewine; [
        ttf-ms-win10
      ])
      ++ (with pkgs; [
        sarasa-gothic # 更纱黑体
      ]);

    # NUR 只被这里的字体使用；仅在 plasma 启用时导入其 overlay，避免 Pi 等
    # 非桌面 host 也承载 NUR 的 module/overlay 依赖（audit §10）。
    nixpkgs.overlays = [
      inputs.nur.overlays.default
      # FIX calibre ebook-viewer env, see also https://discussion.fedoraproject.org/t/calibre-and-wayland/100384/3
      # 用同一 overlay 的 `final` package set 重建完整 calibre（保留全部 bin/share），
      # 只在入口 `calibre` 上强制 QT_QPA_PLATFORM=xcb；不再手工链接单个 binary
      # 并绕过 overlay 的 package set（audit §10）。
      (final: prev: {
        calibre = prev.symlinkJoin {
          name = "calibre-wayland";
          paths = [ prev.calibre ];
          nativeBuildInputs = [ final.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/calibre" --prefix QT_QPA_PLATFORM : xcb
          '';
        };
      })
    ];
  };
}
