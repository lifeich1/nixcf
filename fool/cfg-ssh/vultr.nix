{ config, lib, ... }:
with lib;
let
  cfg = config.fool.cfg-ssh;
in
{
  config = mkIf cfg.vultr {
    home.file.".ssh/config.d/vultr".text = ''
      Host meta
        HostName 144.202.44.234
        User rdq0a
        port 22987
        ForwardAgent Yes

      Host ayu
        HostName 64.176.41.80
        User root
        ForwardAgent Yes

      # vim: filetype=sshconfig
    '';
  };
}
