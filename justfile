default: nixos

update:
  nix flake update --debug

alias u := update

chk *flags:
  nix flake check {{flags}}

NOM_FLAG := "--log-format internal-json -v |& nom --json"

nixos *flags:
  rm -f .prev-system
  ln -s /nix/var/nix/profiles/`readlink /nix/var/nix/profiles/system` .prev-system
  -sudo nixos-rebuild switch --flake . {{flags}} {{NOM_FLAG}}
  test "$(readlink .prev-system)" != "$(readlink /nix/var/nix/profiles/system)"
  nvd diff .prev-system /nix/var/nix/profiles/system

continue *flags:
  sudo nixos-rebuild switch --flake . {{flags}} {{NOM_FLAG}} || echo "error code $?"
  test "$(readlink .prev-system)" != "$(readlink /nix/var/nix/profiles/system)" && \
  nvd diff .prev-system /nix/var/nix/profiles/system

alias cont := continue
alias g := nixos-debug
alias pi := rebuild-pi
alias xps := rebuild-xps
alias gtr7 := rebuild-gtr7

all: chk && rebuild-pi rebuild-xps
  test $(hostname) = "nixos-gtr7"

nixos-debug: chk
  sudo nixos-rebuild switch --flake . --verbose --show-trace --print-build-logs

rebuild-pi *flags: && (tag-deploy "pi")
  nixos-rebuild switch --flake .{{"#nixos-pi4b"}} --target-host root@my-pi {{flags}} {{NOM_FLAG}}

my_xps := "192.168.3.21"

rebuild-xps *flags: && (tag-deploy "xps")
  nixos-rebuild switch --flake .{{"#nixos-xps13"}} --target-host root@{{my_xps}} {{flags}} {{NOM_FLAG}}

#my_gtr7 := "192.168.31.67"
my_gtr7 := "10.42.0.2" # direct connect

rebuild-gtr7 *flags: && (tag-deploy "gtr7")
  nixos-rebuild switch --flake .{{"#nixos-gtr7"}} --target-host root@{{my_gtr7}} {{flags}} {{NOM_FLAG}}

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
# NOTE not helpful if get in source not by pkgs
proxy host="127.0.0.1" tmpfile=("/tmp/111nixdae.override.conf." + temp_tag): && daemon-restart
  echo "[Service]" > {{tmpfile}}
  echo "Environment=\"https_proxy=socks5h://{{host}}:10809\"" >> {{tmpfile}}
  echo "Environment=\"no_proxy={{host_no_proxy}}\"" >> {{tmpfile}}
  sudo mkdir -p /run/systemd/system/nix-daemon.service.d/
  sudo mv -v {{tmpfile}} /run/systemd/system/nix-daemon.service.d/override.conf

no-proxy: && daemon-restart
  sudo rm -f /run/systemd/system/nix-daemon.service.d/override.conf

# show nix-daemon.service environ vars
daemon-env:
  sudo cat /proc/`pidof nix-daemon|awk '{print $1}'`/environ|tr '\0' '\n'

daemon-restart:
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon

# temporarily remove nix-community.cachix.org from substituters
disable-commu: && daemon-restart
  test ! -e /etc/nix/nix.conf.bak
  sed 's/https:\/\/nix-community.cachix.org//' < /etc/nix/nix.conf > /tmp/nix.conf
  perl -pi -e 's/https:\/\/mirrors?\.\S+//g' /tmp/nix.conf
  sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.bak
  sudo mv /tmp/nix.conf /etc/nix/nix.conf

cfg-rollback: && daemon-restart
  test -e /etc/nix/nix.conf.bak
  sudo rm /etc/nix/nix.conf
  sudo mv /etc/nix/nix.conf.bak /etc/nix/nix.conf

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

# test: try prefetch github
test:
  proxychains4 nix flake prefetch github:numtide/flake-utils

print-nix-ver:
  nix eval .#nixosConfigurations.nixos-gtr7.config.nix.package.version

update-history:
  git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" flake.lock

alias hi := update-history

add-app name:
  mkdir fool/{{ name }}
  nvr -p fool/{{ name }}/default.nix fool/default.nix
