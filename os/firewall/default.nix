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
    (mkIf cfg.non-strict {
      networking.firewall = {
        enable = true;
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
      # FIXME pi firewall has bug, only bypass if ssh conn alive
      fool.firewall.non-strict = false;
      networking.firewall.enable = false;
      # networking.firewall.allowedTCPPortRanges = [
      #   {
      #     from = 3000; # site like
      #     to = 4000;
      #   }
      #   {
      #     from = 10000; # daemon srv
      #     to = 11000;
      #   }
      # ];
      # networking.firewall.allowedUDPPortRanges = [
      #   {
      #     from = 3000;
      #     to = 4000;
      #   }
      #   {
      #     from = 10000;
      #     to = 11000;
      #   }
      # ];
    })
  ];
}
