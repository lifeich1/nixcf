{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.fool.cp-guard;
  cp-guard = inputs.cp-guard.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.fool.cp-guard = {
    enable = mkEnableOption "competitive-companion local guard service";
    dir = mkOption {
      description = "set compete dir path";
      type = types.str;
      default = "${config.home.homeDirectory}/hub/rspc-src";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."competitive-companion_local_guard" = {
      Unit = {
        Description = "competitive-companion local guard";
        After = [ "basic.target" ];
        Wants = [ "basic.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Environment = "RUST_LOG=info";
        ExecStart = "${cp-guard}/bin/cp-guard ${cfg.dir}";
      };
    };
  };
}
