{
  config,
  lib,
  ...
}:
with lib;
{
  # 默认拒绝未声明的入站连接；各服务端口由服务 module / host 单一拥有
  #（refactor-plan-04 阶段 3 完成，non-strict option 与宽 range 已删除）。
  config = {
    networking.firewall.enable = true;
  };
}
