# Nix 守护进程配置：GC、substituter、trusted key、netrc 与诊断开关。
#
# substituters / trusted-public-keys / netrc-file 与 Pi 的 Attic 服务相互依赖，
# 修改时与 os/atticd、fool/attic 一起核对；netrc-file 指向 Agenix 运行时文件
# `/run/agenix/attic-netrc`，文档中不复制令牌。
# Attic endpoint/cache/public key 从 os/homelab 的类型化配置派生。
{ config, lib, username, ... }:
with lib;
let
  attic = config.fool.homelab.attic;
in
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [ username ];
    substituters = mkBefore [
      "${attic.endpoint}/${attic.cacheName}" # homelab
      # XXX THU block social heavy thoughtput
      #"https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://mirror.sjtu.edu.cn/nix-channels/store" # XXX outdated
      # NOTE sometimes commu cache corrupted then broke home-manager
      "https://nix-community.cachix.org"
      "https://rewine.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      attic.publicKey # homelab
      "rewine.cachix.org-1:aOIg9PvwuSefg59gVXXxGIInHQI9fMpskdyya2xO+7I="
    ];
    trace-verbose = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    netrc-file = "/run/agenix/attic-netrc";
  };
}
