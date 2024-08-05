{ config, lib, ... }:
with lib;
let
  cfg = config.fool.cfg-ssh;
in
{
  config = mkIf cfg.qcraft {
    home.file.".ssh/config.d/qcraft".text = ''
      Host combk
        HostName 192.168.31.188
        User qcraft
        ForwardAgent Yes

      Host com
        HostName 172.18.18.62
        User qcraft
        ProxyCommand ssh -W %h:%p combk

      # vim: filetype=sshconfig
    '';
  };
}
