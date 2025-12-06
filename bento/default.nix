{
  pkgs,
  ...
}:
{
  rime-moran = pkgs.callPackage ./rime-moran/package.nix { };
}
