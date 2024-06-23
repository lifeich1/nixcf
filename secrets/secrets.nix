let
  pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWlFuekNhGU+i7bpbzE8qlSrR/9IEA0gRYTxXV4Kuna";
  gtr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM90PqsqQZW7/LKOq9lhIQWk0ASsdhoXBxdOjYqq86Ze";
  xps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByt6QnePLW5+FE8T5dpyAOBZET7AqeE6s01Hm/rhEgq";
  builders = [
    gtr
    xps
  ];
  all = [ pi ] ++ builders;
in
{
  "xray-config.json.age".publicKeys = all;
  "pi-pass.age".publicKeys = all;
  "gtr-pass.age".publicKeys = builders;
  "xps-pass.age".publicKeys = builders;
}
