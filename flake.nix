{
  description = "The nixos flake of Lintd";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable";
    nixpkgs-stable.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-24.05";
    #nixpkgs-fork.url = "git+file:/home/fool/Code/z/github.com/NixOS/nixpkgs?shallow=1";
    #nixpkgs-lib.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable&dir=lib";
    home-manager = {
      url = "git+https://gitee.com/mirrors/home-manager-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "git+https://gitee.com/mirrors/nixos-hardware.git";

    #attic.url = "github:zhaofengli/attic";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    nixgl = {
      url = "git+http://my-pi:3000/mirrors/nixGL.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.flake-utils.follows = "flake-utils";
    };
    vim-minpac = {
      url = "git+http://my-pi:3000/mirrors/minpac.git";
      flake = false;
    };

    hobob = {
      url = "github:lifeich1/hobob/deploy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:
    let
      gtr5_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM90PqsqQZW7/LKOq9lhIQWk0ASsdhoXBxdOjYqq86Ze fool@nixos-gtr5";
      base_config = system: {
        inherit
          gtr5_pubkey
          inputs
          system
          nixpkgs
          ;
        all_proxy = false;
        device = "none";
        has_pi = true; # physics environment
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      pi4b_config = (base_config "aarch64-linux") // {
        username = "pi";
        device = "pi4b";
        has_pi = false;
      };

      x64_config = base_config "x86_64-linux";

      add_basic_mods =
        name: mods:
        (
          mods
          ++ [
            ./os
            ./secrets
            ./host/common.nix
            ./host/${name}/configuration.nix
            ./fool/overlays
            inputs.agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            (
              { lib, ... }:
              {
                _module.args = {
                  inherit nixos-hardware;
                };
                home-manager.sharedModules = [ ./fool ];
              }
            )
          ]
        );

      pass_config =
        config: override:
        let
          args = config // override;
          home-nix = args.home-nix or ./home/pc;
        in
        {
          _module.args = args;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${args.username}" = import home-nix;
          home-manager.extraSpecialArgs = args;
          ## XXX failed _module.args, inputs missing
          #home-manager.sharedModules = [ { _module.args = args; } ];
        };

      gtr7-hardware-list = with nixos-hardware.nixosModules; [
        common-pc
        # AMD Ryzen™ 7 7840HS (zen4)
        common-cpu-amd
        common-cpu-amd-pstate
        # XXX zenpower abandoned zen4
        common-cpu-amd-raphael-igpu
        # nvme m2
        common-pc-ssd
      ];

      mods = builtins.mapAttrs add_basic_mods {
        nixos-xps13 = [
          nixos-hardware.nixosModules.dell-xps-13-9360
          (pass_config x64_config {
            username = "fool";
            device = "xps13";
          })
        ];
        nixos-gtr5 = [
          (pass_config x64_config {
            username = "fool";
            device = "gtr5";
          })
        ] ++ gtr7-hardware-list;
        nixos-pi4b = [
          nixos-hardware.nixosModules.raspberry-pi-4
          #inputs.attic.nixosModules.atticd
          ./os/atticd
          (pass_config pi4b_config { home-nix = ./home/micro-srv; })
        ];
      };
    in
    {
      nixosConfigurations.nixos-xps13 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = mods.nixos-xps13;
      };
      nixosConfigurations.nixos-gtr5 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = mods.nixos-gtr5;
      };
      nixosConfigurations.nixos-pi4b = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = mods.nixos-pi4b;
      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
          nodeNixpkgs = {
            pi4b = import nixpkgs { system = "aarch64-linux"; };
          };
        };
        pi4b = {
          deployment = {
            targetHost = "my-pi";
            targetUser = "root";
          };
          imports = mods.nixos-pi4b;
        };
        xps = {
          deployment = {
            targetHost = "192.168.31.224";
            targetUser = "root";
          };
          imports = mods.nixos-xps13;
        };
      };
    };
}
