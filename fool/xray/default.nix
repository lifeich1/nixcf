{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.xray;
  srvpath = ".lintd/xray/default.service";
  homedir = config.home.homeDirectory;
  srv_fullpath = "${homedir}/${srvpath}";
  ro_srvpath = "/usr/local/etc/xray/config.json";
in
{
  options.fool.xray = {
    installer = mkEnableOption ''
      installer `setup-xray`.

      Do not use this at nixos, use nixos module services.xray
    '';
  };

  config = mkIf cfg.installer {
    home.file."${srvpath}".text = ''
      [Unit]
      Description=Xray Service
      Documentation=https://github.com/xtls
      After=network.target nss-lookup.target

      [Service]
      User=nobody
      CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
      AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
      NoNewPrivileges=true
      ExecStart=${pkgs.xray}/bin/xray run -config ${ro_srvpath}
      Restart=on-failure
      RestartPreventExitStatus=23
      LimitNPROC=10000
      LimitNOFILE=1000000

      [Install]
      WantedBy=multi-user.target
    '';

    home.packages = [
      pkgs.xray
      (pkgs.runCommand "setup-xray" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin
        ln -s ${./setup.sh} $out/bin/setup-xray
        wrapProgram $out/bin/setup-xray \
          --add-flags ${srv_fullpath}
      '')
    ];
  };
}
