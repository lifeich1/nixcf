{
  description = "The nixos flake of Lintd";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable";
    nixpkgs-stable.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-26.05";

    ## manual mirrors
    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "git+https://gitee.com/sunn4mirror/home-manager.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      #url = "git+https://gitee.com/zsbaozhilin/NUR.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    #nixos-hardware.url = "git+https://gitee.com/zsbaozhilin/nixos-hardware.git";
    agenix = {
      url = "github:ryantm/agenix";
      #url = "git+https://gitee.com/sunn4mirror/agenix.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    minpac = {
      url = "git+https://gitee.com/zsbaozhilin/minpac.git";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## personal packages
    hobob = {
      url = "git+https://gitee.com/lifeich0/hobob.git/?ref=deploy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cp-guard.url = "git+https://gitee.com/lifeich0/cp-guard.git";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      nixos-hardware,
      nur,
      ...
    }@inputs:
    let
      gtr5_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM90PqsqQZW7/LKOq9lhIQWk0ASsdhoXBxdOjYqq86Ze fool@nixos-gtr5";
      hosts = {
        nixos-xps13 = {
          system = "x86_64-linux";
          username = "fool";
          device = "xps13";
          homeModule = ./home/lightpad;
          hasPi = true;
          extraModules = {
            beforeHome = [ nixos-hardware.nixosModules.dell-xps-13-9360 ];
            afterHome = [ ];
          };
        };
        nixos-gtr7 = {
          system = "x86_64-linux";
          username = "fool";
          device = "gtr7";
          homeModule = ./home/pc;
          hasPi = true;
          extraModules = {
            beforeHome = [ ];
            afterHome = with nixos-hardware.nixosModules; [
              common-pc
              # AMD Ryzen™ 7 7840HS (zen4)
              common-cpu-amd
              common-cpu-amd-pstate
              # XXX zenpower abandoned zen4
              common-cpu-amd-raphael-igpu
              # nvme m2
              common-pc-ssd
            ];
          };
        };
        nixos-pi4b = {
          system = "aarch64-linux";
          username = "pi";
          device = "pi4b";
          homeModule = ./home/micro-srv;
          hasPi = false;
          extraModules = {
            beforeHome = [
              nixos-hardware.nixosModules.raspberry-pi-4
              ./os/atticd
            ];
            afterHome = [ ];
          };
        };
      };

      mkHost =
        name: host:
        let
          args = {
            inherit
              gtr5_pubkey
              inputs
              nixpkgs
              ;
            inherit (host)
              system
              username
              device
              ;
            all_proxy = false;
            has_pi = host.hasPi;
            pkgs-stable = import nixpkgs-stable {
              inherit (host) system;
              config.allowUnfree = true;
            };
          };

          homeModule = {
            _module.args = args;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${host.username}" = import host.homeModule;
            home-manager.extraSpecialArgs = args;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit (host) system;
          modules =
            host.extraModules.beforeHome
            ++ [ homeModule ]
            ++ host.extraModules.afterHome
            ++ [
              ./os
              ./secrets
              ./host/common.nix
              ./host/${name}/configuration.nix
              ./fool/overlays
              nur.modules.nixos.default
              inputs.agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              (
                { lib, ... }:
                {
                  _module.args = {
                    inherit nixos-hardware;
                  };
                  home-manager.sharedModules = [
                    ./fool
                    inputs.nixvim.homeModules.nixvim
                  ];
                }
              )
            ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost hosts;
    };
}
