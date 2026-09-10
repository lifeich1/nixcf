{
  config,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.fool.syncthing;
in
{
  options.fool.syncthing = {
    enable = mkEnableOption "service syncthing";
    # 打开 syncthing 默认端口（上游 services.syncthing.openDefaultPorts：
    # TCP/UDP 22000 + UDP 21027 discovery）。规则由上游 module 拥有，本 wrapper 只做
    # passthrough。
    openFirewall = mkEnableOption "open syncthing firewall ports";
    dataDir = mkOption {
      type = types.path;
      # 从用户 home 派生，不再硬编码 /home/<username>（audit §14）。
      default = "${config.users.users.${username}.home}/公共";
      description = "Syncthing 数据根目录（默认用户的 公共 目录）";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      # 上游 option 名为 openDefaultPorts（tcp/udp 22000 + udp 21027 discovery）
      openDefaultPorts = cfg.openFirewall;
      user = username;
      dataDir = cfg.dataDir;
      # configDir 同样从用户 home 派生，不再硬编码 /home/<username>（audit §14）。
      configDir = "${config.users.users.${username}.home}/.config/syncthing";
      overrideFolders = false;
      overrideDevices = false;
      # folders/devices 个人拓扑见 ./topology.nix，由 GTR7/XPS13 host 显式 imports
      #（refactor-plan-04 阶段 7）。
    };
  };
}
