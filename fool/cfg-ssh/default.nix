{ config, lib, osConfig, ... }:
with lib;
let
  cfg = config.fool.cfg-ssh;
in
{
  options.fool.cfg-ssh = {
    vultr = mkEnableOption "vultr server ssh config";
    qcraft = mkEnableOption "bussiness workbench ssh config";
    soc = mkEnableOption "soc chips ssh config";
  };

  config = mkMerge [
    {
      programs.ssh = {
        enable = true;
        includes = [ "config.d/*" ];
        enableDefaultConfig = false;
        settings."*" = {
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
        settings."github.com" =
          let
            inherit (config.fool.proxy) tcp_url;
          in
          {
            HostName = "github.com";
            ServerAliveInterval = 55;
            ForwardAgent = true;
            ProxyCommand = "nc -X 5 -x ${tcp_url} %h %p";
          };
      };
    }
    (mkIf cfg.vultr {
      programs.ssh.settings = {
        ayu = {
          HostName = "64.176.41.80";
          User = "root";
          ForwardAgent = true;
        };
      };
    })
    (mkIf cfg.qcraft {
      programs.ssh.settings = {
        combk = {
          HostName = "192.168.31.188";
          User = "qcraft";
          ForwardAgent = true;
        };
        com = {
          HostName = "172.18.20.103";
          User = "qcraft";
          ProxyCommand = "ssh -W %h:%p combk";
        };
      };
    })
    (mkIf cfg.soc {
      programs.ssh.settings = {
        lclpi = {
          HostName = osConfig.fool.homelab.pi.lanAddress;
          User = "pi";
        };
        opi1 = {
          HostName = "192.168.3.60";
          User = "root";
        };
        gtr = {
          HostName = "192.168.3.4";
          User = "fool";
        };
      };
    })
  ];
}
