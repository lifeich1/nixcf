{ config, lib, ... }:
with lib;
let
  cfg = config.fool.cfg-ssh;
in
{
  config = mkIf cfg.vultr {
    home.file.".ssh/config.d/vultr".text = ''
      Host ayu
        HostName 64.176.41.80
        User root
        ForwardAgent Yes

      # vim: filetype=sshconfig
    '';
  };
}
