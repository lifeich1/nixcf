let
  # host age identities（迁移过渡期与用户 key 并存，验证后移除用户 key）
  pi-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMA3B775vU4vwQz/+GmXKkwSQp+bAV1bBo1pr2WR/EFu root@nixos";
  gtr-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILHqMwjrgx4w5u5FGbiz1YaBTDSsiv3Seyb+DXUL0whD root@nixos";
  xps-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImSVH1a++X/lwPECgBtrIyIW9ztjizoUzcyi1nXvoxM root@nixos-xps13";
  # 旧用户 key（过渡期保留）
  pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWlFuekNhGU+i7bpbzE8qlSrR/9IEA0gRYTxXV4Kuna";
  gtr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM90PqsqQZW7/LKOq9lhIQWk0ASsdhoXBxdOjYqq86Ze";
  xps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByt6QnePLW5+FE8T5dpyAOBZET7AqeE6s01Hm/rhEgq";
  builders = [
    gtr
    xps
    gtr-host
    xps-host
  ];
  all = [
    pi
    pi-host
  ] ++ builders;
in
{
  "xray-config.json.age".publicKeys = all;
  "pi-pass.age".publicKeys = all;
  "gtr-pass.age".publicKeys = builders;
  "xps-pass.age".publicKeys = builders;
}
