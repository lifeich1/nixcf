{ ... }:

{
  imports = [ ../desktop-common.nix ];

  # Preserve the existing package set; slimming it is a separate change.
  fool.desktop.heavy-apps.enable = true;
  fool.alacritty.font-size = 10;
}
