{
  config,
  lib,
  username,
  device,
  ...
}:
with lib;
{
  options.fool.secrets = {
    pass = mkOption {
      # 只允许仓库中已声明的密码 secret，避免任意 string 动态拼出 secret 名
      # 与文件路径（audit §2）。新增主机时在此枚举与 secrets/secrets.nix 同步。
      type = types.nullOr (
        types.enum [
          "gtr-pass"
          "pi-pass"
          "xps-pass"
        ]
      );
      default = null;
      description = "该主机的登录密码 secret（对应 secrets/<name>.age）";
    };
  };

  config = mkMerge [
    {
      services.xray.settingsFile = config.age.secrets.xray-config.path;
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
        {
          # 密码 secret 名必须对应仓库中真实存在的密文（audit §2）。
          assertion =
            !(isString config.fool.secrets.pass)
            || builtins.pathExists (./. + "/${config.fool.secrets.pass}.age");
          message = "fool.secrets.pass 指向的 secrets/${config.fool.secrets.pass}.age 不存在";
        }
      ];
    }
  ];
}
