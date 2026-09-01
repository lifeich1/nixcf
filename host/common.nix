{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
{
  boot.loader.systemd-boot.configurationLimit = mkDefault 50;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [ username ];
    substituters = mkBefore [
      "http://my-pi:8080/my-pi_attic" # homelab
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
      "my-pi_attic:ryUjSxUOb7D+cBc7Q7MfUXdd0isJWo8kteKETy9x2X0=" # homelab
      "rewine.cachix.org-1:aOIg9PvwuSefg59gVXXxGIInHQI9fMpskdyya2xO+7I="
    ];
    trace-verbose = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    netrc-file = "/run/agenix/attic-netrc";
  };

  services.xray.settingsFile = config.age.secrets.xray-config.path;
}
