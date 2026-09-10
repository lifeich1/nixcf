{
  description = "The nixos flake of Lintd";

  inputs = {
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git/?ref=nixos-unstable";

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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## personal packages
    hobob = {
      url = "git+https://gitee.com/lifeich0/hobob.git/?ref=deploy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cp-guard = {
      url = "git+https://gitee.com/lifeich0/cp-guard.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:
    let
      adminKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM90PqsqQZW7/LKOq9lhIQWk0ASsdhoXBxdOjYqq86Ze fool@nixos-gtr5";
      hosts = import ./hosts.nix { inherit nixos-hardware; };

      mkHost =
        name: host:
        let
          # 系统模块 specialArgs：按各模块真实形参声明裁剪
          sysArgs = {
            inherit adminKeys inputs;
            inherit (host) username device;
          };
          # Home Manager extraSpecialArgs：只传 home 树实际使用的参数
          homeArgs = {
            inherit inputs;
            inherit (host) username;
          };

          homeModule = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${host.username}" = import host.homeModule;
            home-manager.extraSpecialArgs = homeArgs;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit (host) system;
          specialArgs = sysArgs;
          modules =
            host.modules
            ++ [
              homeModule
              ./os
              ./secrets
              ./host/${name}/configuration.nix
              inputs.agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                networking.hostName = nixpkgs.lib.mkForce name;
                home-manager.sharedModules = [
                  ./fool
                  inputs.nixvim.homeModules.nixvim
                ];
              }
            ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost hosts;
      # 不含 secret 的部署元数据，供 justfile 等运维入口查询 target/tag。
      deployTargets = builtins.mapAttrs (name: host: host.deploy) hosts;
      # 非敏感 homelab endpoint（与 os/homelab option 默认值同源），供运维 recipe 查询。
      homelabEndpoints = import ./os/homelab/endpoints.nix;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt;
    };
}
