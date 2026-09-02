# 系统访问策略：root 与主用户的 SSH 授权。
#
# 管理员 public key 集合由 flake.nix 的 `adminKeys`（角色语义）提供，root access
# 在本模块选择它；Pi 的 `pi` 用户 keys 在 host configuration 中显式选择同一来源。
# Agenix recipients 使用 host age identity，与 SSH key 集不通过名字耦合。
{ lib, adminKeys, ... }:
with lib;
{
  users.users.root.openssh.authorizedKeys.keys = [
    adminKeys
    # XPS13 的 fool 用户 key（历史保留的管理员入口）
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByt6QnePLW5+FE8T5dpyAOBZET7AqeE6s01Hm/rhEgq fool@nixos-xps13"
  ];
}
