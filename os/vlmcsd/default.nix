{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.vlmcsd;
  image = "docker.io/mikolatero/vlmcsd:latest";
  port = "1688:1688";
in
{
  options.fool.vlmcsd = {
    enable = mkEnableOption "vlmcsd";
    invokeType = mkOption {
      type = types.enum [
        "cmd"
        "nix"
      ];
      default = "cmd";
      example = "nix";
      description = ''
        Select invoke vlmcsd container type:

        - cmd: directly call podman, easily make proxied.
        - nix: nix way oci-container.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.podman.enable = true;
      networking = {
        firewall = {
          allowedTCPPorts = [
            1688 # vlmcsd
          ];
        };
      };
    }
    (mkIf (cfg.invokeType == "cmd") {
      systemd.services."podman-vlmcsd" = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          https_proxy = "socks5://127.0.0.1:10809";
        };
        script = "${pkgs.podman}/bin/podman run -p ${port} --name vlmcsd --replace ${image}";
      };
    })
    (mkIf (cfg.invokeType == "nix") {
      virtualisation.oci-containers.backend = "podman";
      virtualisation.oci-containers.containers."vlmcsd" = {
        inherit image;
        ports = [ port ];
      };
    })
  ]);
}
