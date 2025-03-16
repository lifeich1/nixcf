{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.hobob;
in
{
  options.fool.hobob = {
    enable = mkEnableOption "hobob";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ hobob ];

    # systemd.user.services."programs-hobob" = {
    #   Unit = {
    #     Description = "Autostart hobob";
    #     After = [ "basic.target" ];
    #     Wants = [ "basic.target" ];
    #   };
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    #   Service = {
    #     WorkingDirectory = "/home/${config.home.username}/hub/hobob";
    #     ExecStart = "${pkgs.hobob}/bin/hobob";
    #   };
    # };
  };
}
