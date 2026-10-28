# DeepSeek Harness CLI：通过 deepseek-harness overlay 提供的 pkgs.dsh 安装，
# 并使用其 Home Manager 模块的 profiles 选项声明插件组合。
#
# 这是仓库“不使用全局 overlay”约定的例外：overlay 仅在 flake.nix 中为
# x86_64-linux host 注入，启用点必须显式传入 pkgs.dsh.dsh 与该 profile 的 bundles。
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.fool.dsh;
in
{
  imports = [ inputs.deepseek-harness.homeModules.default ];

  options.fool.dsh = {
    enable = lib.mkEnableOption "DeepSeek Harness CLI";

    package = lib.mkOption {
      type = lib.types.package;
      description = "dsh CLI package，由启用点传入 pkgs.dsh.dsh";
    };

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "web";
      description = "Nix 管理的 dsh profile 名称；materialized 后为 nix-<name>";
    };

    bundles = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "该 profile 的 dsh bundle 列表，例如 pkgs.dsh.bundles.web-app";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "managed"
        "mutable"
      ];
      default = "managed";
      description = "profile 同步模式；managed 每次运行恢复声明文件，mutable 仅首次 seed";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dsh = {
      enable = true;
      package = cfg.package;
      profiles.${cfg.profileName} = {
        bundles = cfg.bundles;
        mode = cfg.mode;
      };
      defaultProfile = config.programs.dsh.profiles.${cfg.profileName}.materializedName;
    };
  };
}
