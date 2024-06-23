{ config, lib, ... }:
with lib;
let
  cfg = config.fool.proxy;
in
{
  config = mkMerge [
    {
      programs.proxychains = {
        enable = true;
        proxies = {
          lray = {
            enable = true;
            type = "socks5";
            host = mkDefault "127.0.0.1";
            port = 10809;
          };
        };
      };
    }
    (mkIf (cfg.has-pi && cfg.use-pi) { programs.proxychains.proxies.lray.host = "my-pi"; })
  ];
}
