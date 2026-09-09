# Reasonix 全局 skill 的声明式部署。
#
# `~/.reasonix/skills/` 是 Reasonix CLI 的全局 skill 目录：其中的 skill 对任意
# 项目生效，而仓库 `.agents/skills/` 只对 nixcf 自身生效。本模块把仓库内的
# skill 源目录链接到全局目录，使 skill 随 Home Manager activation 生效，
# 不依赖手工复制。
{ config, lib, ... }:
with lib;
let
  cfg = config.fool.reasonix;
in
{
  options.fool.reasonix.skills = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        把 fool/reasonix/skills/ 下的全局 skill 链接到 ~/.reasonix/skills/。
        目标已存在同名普通文件/目录时 Home Manager 会报冲突，需先手工清理。
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.skills.enable) {
    home.file.".reasonix/skills/labyrinth-dimension" = {
      source = ./skills/labyrinth-dimension;
    };
  };
}
