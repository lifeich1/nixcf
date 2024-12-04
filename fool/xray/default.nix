{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.xray;
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
    home.packages =
      with pkgs;
      let
        setup-xray = writeShellApplication {
          name = "setup-xray";
          text = ''
            if [ ! -f ${ro_srvpath} ]; then
              echo "Please config ${ro_srvpath} first!";
              exit 1
            fi
            cat << END
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
            END | sudo tee /etc/systemd/system/xray.service && \
            sudo systemctl daemon-reload && \
            sudo systemctl enable xray.service && \
            sudo systemctl restart xray.service && \
            journalctl -f -u xray.service
          '';
        };
      in
      [
        xray
        setup-xray
      ];
  };
}
