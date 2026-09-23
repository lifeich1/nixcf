# Podman 用户级配置：docker.io 仓库镜像（registries.conf.d drop-in）。
#
# Home Manager 的 `services.podman.settings.registries.registry` submodule 只支持
# location/insecure/blocked，无法表达 `[[registry.mirror]]`，故在
# `~/.config/containers/registries.conf.d/` 放置 drop-in；podman 会把它与 HM 生成的
# 主 `registries.conf`（含 unqualified-search-registries）自动合并。
#
# 只在 gtr7 (home/pc) 启用；bililiverecorder 模块中的 `services.podman.enable`
# 保持独立（值相同，mkIf 合并无冲突）。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.podman;
in
{
  options.fool.podman = {
    enable = mkEnableOption "podman user config (docker.io registry mirrors)";
  };

  config = mkIf cfg.enable {
    services.podman.enable = true;

    # 与主 registries.conf 合并，等效于：
    #   [[registry]]
    #   prefix = "docker.io"
    #   location = "docker.io"
    #   [[registry.mirror]] ... x3
    xdg.configFile."containers/registries.conf.d/00-docker-mirrors.conf".text = ''
      [[registry]]
      prefix = "docker.io"
      location = "docker.io"

        [[registry.mirror]]
        location = "docker.xuanyuan.me"

        [[registry.mirror]]
        location = "docker.1ms.run"

        [[registry.mirror]]
        location = "docker.m.daocloud.io"
    '';
  };
}
