{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.virtualbox;
in
{
  options.fool.virtualbox = {
    enable = mkEnableOption "virtualbox";
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "fool" ];
      description = "加入 vboxusers 组的用户（host 显式列出，不再手写 extraGroups）";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true; # for enableExtensionPack
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      enableKvm = true;
      addNetworkInterface = false; # bind with enableKvm
    };
    # vboxusers 组成员由本 module 统一派生（refactor-plan-04 阶段 9），
    # 避免 host 文件重复 group 约定。
    users.users = listToAttrs (map (name: {
      inherit name;
      value.extraGroups = [ "vboxusers" ];
    }) cfg.users);
  };
}
