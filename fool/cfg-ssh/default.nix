{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.cfg-ssh;
in
{
  options.fool.cfg-ssh = {
    # 个人 SSH host 数据由 profile/data 层提供；模块只定义类型，不含真实 endpoint。
    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          hostName = mkOption {
            type = types.str;
            description = "SSH HostName";
          };
          user = mkOption {
            type = types.str;
            default = "root";
            description = "SSH user";
          };
          forwardAgent = mkOption {
            type = types.bool;
            default = false;
            description = "enable ForwardAgent for this host";
          };
          proxyCommand = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "ProxyCommand override (e.g. ssh -W %h:%p hop)";
          };
        };
      });
      default = { };
      description = "personal ssh host aliases, keyed by alias name";
    };
  };

  config = {
    programs.ssh = {
      enable = true;
      includes = [ "config.d/*" ];
      enableDefaultConfig = false;
    };
    # 基线与个人 SSH host 数据合并为一个 settings。
    programs.ssh.settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
      "github.com" =
        let
          inherit (config.fool.proxy) tcp_url;
        in
        {
          HostName = "github.com";
          ServerAliveInterval = 55;
          ForwardAgent = true;
          ProxyCommand = "nc -X 5 -x ${tcp_url} %h %p";
        };
    } // mapAttrs' (
      name: h:
      nameValuePair name ({
        HostName = h.hostName;
        User = h.user;
      } // lib.optionalAttrs h.forwardAgent { ForwardAgent = true; }
        // lib.optionalAttrs (h.proxyCommand != null) { ProxyCommand = h.proxyCommand; })
    ) cfg.hosts;
  };
}