{
  config,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.fool.sudo;
in
{
  options.fool.sudo = {
    nopass = mkEnableOption "option NOPASSWD";
  };

  # NOPASSWD 由本模块直接构造 rule，不再暴露内部拼接用的 extra-options
  # （audit §16）。
  config = {
    security.sudo.extraRules = [
      {
        users = [ "${username}" ];
        commands = [
          {
            command = "ALL";
            options = optionals cfg.nopass [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
