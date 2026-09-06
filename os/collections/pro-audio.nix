# pro-audio collection：JACK（经 PipeWire）+ 实时调度限制（rtprio/memlock）。
#
# refactor-plan-04 阶段 9 决策：GTR7 与 XPS13 都有 JACK/实时音频工作流，两台都启用
# 本 profile；拆分只是把原 fool.collections.gtr 的隐式集合显式化，不改变限制值。
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.collections;
in
{
  options.fool.collections = {
    pro-audio = mkEnableOption "pro audio collection: JACK + realtime loginLimits";
  };

  config = mkIf cfg.pro-audio {
    # If you want to use JACK applications
    services.pipewire.jack.enable = true;

    # NOTE for guitarix
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "memlock";
        value = "8192000";
      }
      {
        domain = "*";
        type = "-";
        item = "rtprio";
        value = "95";
      }
    ];
  };
}
