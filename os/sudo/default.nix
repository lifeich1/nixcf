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
    extra-options = mkOption {
      internal = true;
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkMerge [
    {
      security.sudo.extraRules = [
        {
          users = [ "${username}" ];
          commands = [
            {
              command = "ALL";
              options = cfg.extra-options;
            }
          ];
        }
      ];
    }
    (mkIf cfg.nopass { fool.sudo.extra-options = [ "NOPASSWD" ]; })
  ];
}
