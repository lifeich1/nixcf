{ config, lib, ... }:
with lib;
let
  cfg = config.fool.firewall;
in
{
  options.fool.firewall = {
    non-strict = mkOption {
      type = types.bool;
      default = true;
      description = "non strict mode, allow tcp/udp 2048-*.";
    };
    serve-hobob = mkEnableOption "open hobob port tcp:3731";
    serve-friedegg = mkEnableOption "open friedegg(gitea) port tcp:3000";
  };

  config = mkMerge [
    { networking.firewall.enable = true; }
    (mkIf cfg.non-strict {
      networking.firewall = {
        allowedTCPPortRanges = [
          {
            from = 2048;
            to = 65535;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 2048;
            to = 65535;
          }
        ];
      };
    })
    (mkIf cfg.serve-hobob {
      networking.firewall = {
        allowedTCPPorts = [
          3731
        ];
      };
    })
    (mkIf cfg.serve-friedegg {
      networking.firewall = {
        allowedTCPPorts = [
          3000
        ];
      };
    })
  ];
}
