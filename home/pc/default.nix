{ pkgs, ... }:

{
  imports = [ ../desktop-common.nix ];

  home.packages = with pkgs; [
    # trials on one host
    charasay
  ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };

  fool.bililiverecorder.enable = true;
  fool.cp-guard.enable = true;
  fool.nvim = {
    ai = true;
    nightly = false;
  };
  fool.alacritty.font-size = 11;
  fool.wezterm.enable = true;
  fool.attic.watch-store = true;
}
