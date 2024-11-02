{
  config,
  lib,
  username,
  ...
}:
let
  cfg = config.fool.secrets;
in
with lib;
{
  options.fool.secrets = {
    pass = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "choose which password file to use";
    };
  };

  config = mkMerge [
    {
      age.secrets = {
        xray-config = {
          file = ./xray-config.json.age;
          path = "/usr/local/etc/xray/config.json";
          mode = "444";
          symlink = false;
        };
      };
      age.identityPaths = [ "/home/${username}/.ssh/id_ed25519" ];
    }
    (mkIf (isString config.fool.secrets.pass) {
      age.secrets."${config.fool.secrets.pass}".file = ./${config.fool.secrets.pass}.age;
      users.users."${username}".hashedPasswordFile =
        config.age.secrets."${config.fool.secrets.pass}".path;
    })
  ];
}
