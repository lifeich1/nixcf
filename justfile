default: nixos

update:
  nix flake update --debug

alias u := update

chk *flags:
  nix flake check {{flags}}

nom_flag := "--log-format internal-json -v |& nom --json"

nixos *flags:
  rm -f .prev-system
  ln -s /nix/var/nix/profiles/`readlink /nix/var/nix/profiles/system` .prev-system
  sudo nixos-rebuild switch --flake . {{flags}} {{nom_flag}}
  nvd diff .prev-system /nix/var/nix/profiles/system

alias g := nixos-debug
alias pi := rebuild-pi
alias xps := rebuild-xps

all: chk && rebuild-pi rebuild-xps
  test $(hostname) = "nixos-gtr5"

nixos-debug: chk
  sudo nixos-rebuild switch --flake . --verbose --show-trace --print-build-logs

colmena-pi *flags: && (tag-deploy "pi")
  colmena apply --on pi4b {{flags}}

rebuild-pi *flags: && (tag-deploy "pi")
  nixos-rebuild switch --flake .{{"#nixos-pi4b"}} --target-host root@my-pi {{flags}} {{nom_flag}}

my_xps := "192.168.31.224"

colmena-xps *flags: && (tag-deploy "xps")
  colmena apply --on xps {{flags}}

rebuild-xps *flags: && (tag-deploy "xps")
  nixos-rebuild switch --flake .{{"#nixos-xps13"}} --target-host root@{{my_xps}} {{flags}} {{nom_flag}}

# hardlink nvim config files for fast dev
nvim:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd ./fool/nvim
  cp -lb vimrc ~/.vimrc
  cp -lb init.lua ~/.vim/init.lua
  cp -lb init.vim ~/.config/nvim/init.vim
  [ -f ~/.lintd/nvim/lsp.lua ] && cp -lb lsp.lua ~/.lintd/nvim/lsp.lua

# hardlink zsh config files for fast dev
zsh:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd ./fool/zsh
  cp -lb zshrc zshenv p10k.zsh ~/.lintd/zsh/

# some recorded fix ops after upgrade
fix: fix-alsa-store

# fix alsa hardware params
fix-alsa-store:
  sudo alsactl store

du_result := "/tmp/nix-du-result.svg"

# run & show nix-du result
du:
  nix-du -s=500MB | dot -Tsvg > {{du_result}}
  gwenview {{du_result}}

temp_tag := `date +%N`
host_no_proxy := "127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn,gitee.com"
# temporarily add proxy settings to nix-daemon.service environ vars
proxy host="127.0.0.1" tmpfile=("/tmp/111nixdae.override.conf." + temp_tag):
  echo "[Service]" > {{tmpfile}}
  echo "Environment=\"https_proxy=socks5h://{{host}}:10809\"" >> {{tmpfile}}
  echo "Environment=\"no_proxy={{host_no_proxy}}\"" >> {{tmpfile}}
  sudo mkdir /run/systemd/system/nix-daemon.service.d/
  sudo mv -v {{tmpfile}} /run/systemd/system/nix-daemon.service.d/override.conf
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon

# show nix-daemon.service environ vars
daemon-env:
  sudo cat /proc/`pidof nix-daemon|awk '{print $1}'`/environ|tr '\0' '\n'

# temporarily remove nix-community.cachix.org from substituters
disable-commu:
  sed 's/https:\/\/nix-community.cachix.org//' < /etc/nix/nix.conf > /tmp/nix.conf
  sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.bak
  sudo mv /tmp/nix.conf /etc/nix/nix.conf

[private]
tag-deploy type:
  #!/usr/bin/env perl
  my $n = 0;
  foreach(split /\n/,qx/git tag -l/) {
    if (/{{type}}-r(\d+)/) {
      $n = $1 if $n < $1;
    }
  }
  print "-- found latest revision number: $n\n";
  $n += 1;
  print "-- tagging '{{type}}-r$n'\n";
  exec qq/git tag {{type}}-r$n/;
