# Competitive Programming Guard：用户级服务。
#
# `fool.cp-guard.enable` 控制服务；`fool.cp-guard.package` 由启用点（home/pc profile）
# 显式传入 `inputs.cp-guard.packages.${pkgs.stdenv.hostPlatform.system}.default`，
# 本模块不再直接接收完整 `inputs`。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.cp-guard;
in
{
  options.fool.cp-guard = {
    enable = mkEnableOption "competitive-companion local guard service";
    package = mkOption {
      type = types.package;
      description = "cp-guard package（启用点传入当前架构的 input package）";
    };
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
        ExecStart = "${cfg.package}/bin/cp-guard ${cfg.dir}";
      };
    };
  };
}
