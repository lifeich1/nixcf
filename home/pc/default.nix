{ pkgs, inputs, ... }:

{
  imports = [ ../common.nix ../desktop-common.nix ];

  home.packages = with pkgs; [
    # trials on one host
    charasay
  ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };

  fool.bililiverecorder.enable = true;
  fool.cp-guard = {
    enable = true;
    package = inputs.cp-guard.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  fool.desktop.heavy-apps.enable = true;
  fool.nvim = {
    ai = true;
  };
  fool.alacritty.font-size = 11;
  fool.wezterm.enable = true;
  fool.attic.watch-store = true;
}
