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
    serve-pi = mkEnableOption "open pi serve ports";
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
    (mkIf cfg.serve-pi {
      networking.firewall.allowedTCPPortRanges = [
        {
          from = 3000;
          to = 4000;
        }
      ];
    })
  ];
}
