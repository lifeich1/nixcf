{
  config,
  lib,
  username,
  device,
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
          mode = "0400";
          symlink = false;
        };
        attic-netrc = {
          file = ./attic-netrc-${device}.age;
          path = "/run/agenix/attic-netrc";
          mode = "0400";
          owner = "root";
          group = "root";
        };
      };
      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    }
    (mkIf (device == "pi4b") {
      age.secrets.atticd-env = {
        file = ./atticd-env.age;
        path = "/run/agenix/atticd-env";
        mode = "0400";
        owner = "root";
        group = "root";
      };
    })
    (mkIf (device == "gtr7") {
      age.secrets.attic-client-config = {
        file = ./attic-client-config.age;
        path = "/run/agenix/attic-client-config";
        mode = "0400";
        owner = username;
        group = "root";
      };
    })
    (mkIf (isString config.fool.secrets.pass) {
      age.secrets."${config.fool.secrets.pass}".file = ./${config.fool.secrets.pass}.age;
      users.users."${username}".hashedPasswordFile =
        config.age.secrets."${config.fool.secrets.pass}".path;
    })
    {
      assertions = [
        {
          assertion = device != "pi4b" || !(config.age.secrets ? attic-client-config);
          message = "attic-client-config (watch-store push token) must not be declared on pi4b";
        }
        {
          assertion = device != "gtr7" || (config.age.secrets ? attic-client-config);
          message = "attic-client-config (watch-store push token) must be declared on gtr7";
        }
        {
          assertion = device != "pi4b" || (config.age.secrets ? atticd-env);
          message = "atticd-env must be declared on pi4b";
        }
      ];
    }
  ];
}
