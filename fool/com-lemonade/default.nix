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
        runtimeInputs = [ lemonade openssh ];
        text = ''
          set -euo pipefail
          stdbuf -oL lemonade server &
          lemon=$!
          trap 'kill "$lemon" 2>/dev/null || true' EXIT
          sleep 0.5
          if ! kill -0 "$lemon" 2>/dev/null; then
            echo "lemonade server failed to start" >&2
            exit 1
          fi
          ssh -vNR 2489:127.0.0.1:2489 "''${1:-com}"
        '';
      })
    ];
  };
}