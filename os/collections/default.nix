{ pkgs, ... }:
{
  imports = [
    ./audio.nix
    ./desktop.nix
    ./pro-audio.nix
  ];

  # collection 特有 package；基础工具 vim/wget/git 由 os/default.nix 统一提供
  config = {
    environment.systemPackages = with pkgs; [
      dmidecode
    ];
  };
}
