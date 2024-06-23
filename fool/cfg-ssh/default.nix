{ config, lib, ... }:
with lib;
let
  cfg = config.fool.cfg-ssh;
in
{
  options.fool.cfg-ssh = {
    vultr = mkEnableOption "vultr server ssh config";
    qcraft = mkEnableOption "bussiness workbench ssh config";
  };

  imports = [
    ./vultr.nix
    ./qcraft.nix
  ];

  config = {
    home.file.".ssh/config".text = ''
      Include config.d/*
    '';
    home.file.".ssh/config.d/github".text =
      let
        inherit (config.fool.proxy) tcp_url;
      in
      ''
        Host github.com
          HostName github.com
          ServerAliveInterval 55
          ForwardAgent yes
          ProxyCommand nc -X 5 -x ${tcp_url} %h %p

        # vim: filetype=sshconfig
      '';
  };
}
