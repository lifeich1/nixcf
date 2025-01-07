{
  description = "The nixos flake of Lintd";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable";
    nixpkgs-stable.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-24.05";

    ## manual mirrors
    home-manager = {
      url = "git+https://gitee.com/sunn4mirror/home-manager.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "git+https://gitee.com/zsbaozhilin/NUR.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "git+https://gitee.com/zsbaozhilin/nixos-hardware.git";
    agenix = {
      url = "git+https://gitee.com/sunn4mirror/agenix.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    minpac = {
      url = "git+https://gitee.com/zsbaozhilin/minpac.git";
      flake = false;
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
            nur.modules.nixos.default
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
            home-nix = ./home/lightpad;
          })
        ];
        nixos-gtr7 = [
          (pass_config x64_config {
            username = "fool";
            device = "gtr7";
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
      nixosConfigurations = with nixpkgs.lib; {
        nixos-xps13 = nixosSystem {
          system = "x86_64-linux";
          modules = mods.nixos-xps13;
        };
        nixos-gtr7 = nixosSystem {
          system = "x86_64-linux";
          modules = mods.nixos-gtr7;
        };
        nixos-pi4b = nixosSystem {
          system = "aarch64-linux";
          modules = mods.nixos-pi4b;
        };
      };
    };
}
