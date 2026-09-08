{ pkgs, lib, minpac, homeDirectory }:
# base configuration aggregator: split by behavior into plugins.nix,
# editor.nix, keymaps.nix and workflow.nix (see readme.md).
# Fragments are merged inside one module so nixvim config option ordering
# (e.g. types.lines extraConfigVim) is preserved exactly as before the split.
{
  config = lib.mkMerge [
    (import ./plugins.nix { inherit pkgs lib minpac; })
    (import ./editor.nix { inherit lib; })
    (import ./keymaps.nix { inherit lib; })
    (import ./workflow.nix { inherit lib homeDirectory; })
  ];
}