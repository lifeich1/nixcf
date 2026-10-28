# DeepSeek Harness CLI：通过 deepseek-harness overlay 提供的 pkgs.dsh 安装，
# 并使用其 Home Manager 模块的 profiles 选项声明插件组合。
#
# 这是仓库“不使用全局 overlay”约定的例外：overlay 仅在 flake.nix 中为
# x86_64-linux host 注入，启用点必须显式传入 pkgs.dsh.dsh 与各 profile 的 bundles。
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.fool.dsh;

  # upstream 的 runtime 包在组合时会清空 profiles，导致 dshBundleCheckHook
  # 丢失 tui profile 的 TTY 标记；这里显式回传给构建期检查。
  ttyProfiles = lib.concatStringsSep " " (
    lib.flatten (
      lib.mapAttrsToList (
        name: profile:
        lib.optional (lib.any (bundle: bundle.passthru.requiresTty or false) profile.bundles) "nix-${name}"
      ) cfg.profiles
    )
  );
in
{
  imports = [ inputs.deepseek-harness.homeModules.default ];

  options.fool.dsh = {
    enable = lib.mkEnableOption "DeepSeek Harness CLI";

    package = lib.mkOption {
      type = lib.types.package;
      description = "dsh CLI package，由启用点传入 pkgs.dsh.dsh";
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            bundles = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              description = "该 profile 的 dsh bundle 列表，例如 pkgs.dsh.bundles.tui";
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
        }
      );
      default = { };
      description = "Nix 管理的 dsh profile；key 为 profile 名称，materialized 后为 nix-<name>";
    };

    defaultProfile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "默认 profile 的 key（不加 nix- 前缀），必须是 fool.dsh.profiles 中的一项";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.defaultProfile == null || cfg.profiles ? ${cfg.defaultProfile};
        message = "fool.dsh.defaultProfile 必须是 fool.dsh.profiles 中已声明的 key";
      }
    ];

    programs.dsh = {
      enable = true;
      package =
        if ttyProfiles == "" then
          cfg.package
        else
          cfg.package.overrideAttrs (_: {
            dshBundleCheckTtyProfiles = ttyProfiles;
          });
      profiles = lib.mapAttrs (_: profile: {
        inherit (profile) bundles mode;
      }) cfg.profiles;
      defaultProfile = if cfg.defaultProfile == null then null else "nix-${cfg.defaultProfile}";
    };
  };
}
