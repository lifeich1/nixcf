# Hobob 系统服务
#
# `default.nix` 声明 `fool.hobob.sys-service` 与 `fool.hobob.package`：启用时以
# `/opt/hobob` 为工作目录运行 `programs-hobob` service。
#
# package 由启用点（`host/nixos-pi4b/configuration.nix`）显式传入
# `inputs.hobob.packages.${pkgs.stdenv.hostPlatform.system}.default`，不再通过
# overlay 注入隐式 `pkgs.hobob`。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.hobob;
in
{
  options.fool.hobob = {
    sys-service = mkEnableOption "hobob sys service";
    package = mkOption {
      type = types.package;
      description = "hobob package（由启用点显式传入当前架构的 input package）";
    };
  };

  config = mkIf cfg.sys-service {
    systemd.services."programs-hobob" = {
      description = "Autostart hobob";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${cfg.package}/bin/hobob";
      serviceConfig = {
        WorkingDirectory = "/opt/hobob";
      };
    };
  };
}
