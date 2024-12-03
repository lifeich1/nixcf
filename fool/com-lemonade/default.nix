{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fool.com-lemonade;
in
{
  options.fool.com-lemonade = {
    enable = mkEnableOption "com-lemonade: proxy com's lemonade";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellApplication {
        name = "com-lemonade";
        runtimeInputs = [ lemonade ];
        text = ''
          lemonade server &
          lemon=$!
          trap 'kill $lemon' EXIT
          ssh -vNR 2489:127.0.0.1:2489 "''${1:-com}"
        '';
      })
    ];
  };
}
