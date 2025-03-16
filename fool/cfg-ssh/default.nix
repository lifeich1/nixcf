{ config, lib, ... }:
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
        matchBlocks."github.com" =
          let
            inherit (config.fool.proxy) tcp_url;
          in
          {
            hostname = "github.com";
            serverAliveInterval = 55;
            forwardAgent = true;
            proxyCommand = "nc -X 5 -x ${tcp_url} %h %p";
          };
      };
    }
    (mkIf cfg.vultr {
      programs.ssh.matchBlocks = {
        ayu = {
          hostname = "64.176.41.80";
          user = "root";
          forwardAgent = true;
        };
      };
    })
    (mkIf cfg.qcraft {
      programs.ssh.matchBlocks = {
        combk = {
          hostname = "192.168.3.7";
          user = "qcraft";
          forwardAgent = true;
        };
        com = {
          hostname = "172.18.20.89";
          user = "qcraft";
          proxyCommand = "ssh -W %h:%p combk";
        };
      };
    })
    (mkIf cfg.soc {
      programs.ssh.matchBlocks = {
        lclpi = {
          hostname = "192.168.3.6";
          user = "pi";
        };
        opi1 = {
          hostname = "192.168.3.60";
          user = "root";
        };
        gtr = {
          hostname = "192.168.3.4";
          user = "fool";
        };
      };
    })
  ];
}
