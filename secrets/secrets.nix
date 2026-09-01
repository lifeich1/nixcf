let
  # host age identities（系统 secret 只授权 host key）
  pi-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMA3B775vU4vwQz/+GmXKkwSQp+bAV1bBo1pr2WR/EFu root@nixos";
  gtr-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILHqMwjrgx4w5u5FGbiz1YaBTDSsiv3Seyb+DXUL0whD root@nixos";
  xps-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImSVH1a++X/lwPECgBtrIyIW9ztjizoUzcyi1nXvoxM root@nixos-xps13";
  builders = [
    gtr-host
    xps-host
  ];
  all = [
    pi-host
  ] ++ builders;
in
{
  "xray-config.json.age".publicKeys = all;
  "pi-pass.age".publicKeys = all;
  "gtr-pass.age".publicKeys = builders;
  "xps-pass.age".publicKeys = builders;
  "atticd-env.age".publicKeys = [ pi-host ];
  "attic-netrc-pi4b.age".publicKeys = [ pi-host ];
  "attic-netrc-gtr7.age".publicKeys = [ gtr-host ];
  "attic-netrc-xps13.age".publicKeys = [ xps-host ];
  "attic-client-config.age".publicKeys = [ gtr-host ];
}
