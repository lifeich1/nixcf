{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.attic;
in
{
  options.fool.attic = {
    watch-store = mkEnableOption "enable watch store service";
  };

  config = mkIf cfg.watch-store {
    home.packages = with pkgs; [
      attic-client
    ];

    systemd.user.services."attic-watch-store" = {
      Unit = {
        Description = "Watch the Nix Store for new paths and upload them to a binary cache";
        After = [ "basic.target" ];
        Wants = [ "basic.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.attic-client}/bin/attic watch-store my-pi_attic";
      };
    };
    xdg.configFile."attic/config.toml".source = ./attic-client.toml;
  };
}
