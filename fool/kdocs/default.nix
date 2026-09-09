# kdocs：kdocs-cli 二进制与 Reasonix 全局 skill。
#
# skill 内容随官网更新，不进入 nixcf 仓库：仓库只固定 `source.json` 的
# version 与两个 hash，由 `just update-kdocs` 刷新。skill 由 Nix 接管，符号链接到
# `~/.reasonix/skills/kdocs`（只读、可复现）；CLI 由 `package.nix` 安装到用户环境。
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fool.kdocs;
  source = builtins.fromJSON (builtins.readFile ./source.json);

  skillZip = pkgs.fetchurl {
    url = "https://wpsai.wpscdn.cn/skillhub/pro/v${source.version}/kdocs.zip";
    hash = source.skillHash;
  };

  # zip 条目使用反斜杠路径（Windows 风格）；Info-ZIP unzip 会转换并生成顶层
  # `kdocs/` 目录，但对这种归档输出 warning 并以退出码 1 结束（1=warning，
  # 2=error）。只容忍 1，并在构建期断言结构，避免静默产出错误布局。
  skillSource =
    pkgs.runCommandLocal "kdocs-skill-${source.version}"
      {
        nativeBuildInputs = [ pkgs.unzip ];
      }
      ''
        mkdir -p "$out"
        rc=0
        unzip -q ${skillZip} -d "$out" || rc=$?
        if [ "$rc" -gt 1 ]; then
          echo "unzip failed with exit code $rc" >&2
          exit "$rc"
        fi
        test -f "$out/kdocs/SKILL.md"
      '';
in
{
  options.fool.kdocs = {
    enable = lib.mkEnableOption "kdocs CLI 与 Reasonix 全局 skill";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "fool.kdocs supports only x86_64-linux";
      }
    ];

    home.packages = [ (pkgs.callPackage ./package.nix { }) ];

    # Nix 接管 skill 目录：符号链接到 store，只读且始终等于 source.json。
    # CLI 与 skill 由同一 source.json 固定，版本恒等，官方 SKILL.md 的
    # 「保持最新版本」两条触发条件（CLI 低于 skill、skill 低于 CLI）都不会成立，
    # 因此只读不会阻断官方流程；升级统一走 `just update-kdocs` + 重新 activation。
    home.file.".reasonix/skills/kdocs".source = "${skillSource}/kdocs";
  };
}
