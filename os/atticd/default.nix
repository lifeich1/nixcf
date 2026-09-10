{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.fool.atticd;
  homelab = config.fool.homelab;
in
{
  options.fool.atticd = {
    enable = mkEnableOption "atticd";
    # Attic 供 gtr7/xps13 客户端（os/nix 的 substituter）访问；规则由本
    # module 拥有，收紧前须显式开启。端口默认 8080（fool.homelab.attic.port）。
    openFirewall = mkEnableOption "open atticd port tcp:8080 (LAN access)";
    listenAddress = mkOption {
      type = types.str;
      default = "[::]";
      description = "atticd listen address（含方括号的 IPv6 字面量或 IPv4）";
    };
    port = mkOption {
      type = types.port;
      default = homelab.attic.port;
      description = "atticd 服务端口；默认与 fool.homelab.attic.port 一致";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.attic-server;
      description = "atticd package";
    };
    retention = mkOption {
      type = types.str;
      default = "6 months";
      description = "garbage-collection.default-retention-period";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.atticd = {
        enable = true;
        inherit (cfg) package;
        environmentFile = "/run/agenix/atticd-env";
        settings = {
          listen = "${cfg.listenAddress}:${toString cfg.port}";

          # Data chunking
          #
          # Warning: If you change any of the values here, it will be
          # difficult to reuse existing chunks for newly-uploaded NARs
          # since the cutpoints will be different. As a result, the
          # deduplication ratio will suffer for a while after the change.
          #
          # 这些值与现有数据格式绑定，refactor-plan-04 明确保持原值，不做 option。
          chunking = {
            # The minimum NAR size to trigger chunking
            #
            # If 0, chunking is disabled entirely for newly-uploaded NARs.
            # If 1, all NARs are chunked.
            nar-size-threshold = 64 * 1024; # 64 KiB

            # The preferred minimum size of a chunk, in bytes
            min-size = 16 * 1024; # 16 KiB

            # The preferred average size of a chunk, in bytes
            avg-size = 64 * 1024; # 64 KiB

            # The preferred maximum size of a chunk, in bytes
            max-size = 256 * 1024; # 256 KiB
          };

          garbage-collection.default-retention-period = cfg.retention;
        };
      };
    })
    (mkIf cfg.openFirewall {
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    })
  ];
}
