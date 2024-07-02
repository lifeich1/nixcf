default: nixos

chk *flags:
  nix flake check {{flags}}

nom_flag := "--log-format internal-json -v |& nom --json"

nixos *flags:
  sudo nixos-rebuild switch --flake . {{flags}} {{nom_flag}}

alias g := nixos-debug
alias pi := rebuild-pi
alias xps := rebuild-xps

all: chk && rebuild-pi rebuild-xps
  test $(hostname) = "nixos-gtr5"

nixos-debug: chk
  sudo nixos-rebuild switch --flake . --verbose --show-trace --print-build-logs

colmena-pi *flags:
  colmena apply --on pi4b {{flags}}

rebuild-pi *flags:
  nixos-rebuild switch --flake .{{"#nixos-pi4b"}} --target-host root@my-pi {{flags}} {{nom_flag}}

my_xps := "192.168.31.224"

colmena-xps *flags:
  colmena apply --on xps {{flags}}

rebuild-xps *flags:
  nixos-rebuild switch --flake .{{"#nixos-xps13"}} --target-host root@{{my_xps}} {{flags}} {{nom_flag}}

nvim:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd ./assets/nvim
  cp -lb vimrc ~/.vimrc
  cp -lb init.lua ~/.vim/init.lua
  cp -lb init.vim ~/.config/nvim/init.vim
  [ -f ~/.lintd/nvim/lsp.lua ] && cp -lb lsp.lua ~/.lintd/nvim/lsp.lua

zsh:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd ./fool/zsh
  cp -lb zshrc zshenv p10k.zsh ~/.lintd/zsh/

fix: fix-alsa-store

fix-alsa-store:
  sudo alsactl store

du_result := "/tmp/nix-du-result.svg"

du:
  nix-du -s=500MB | dot -Tsvg > {{du_result}}
  gwenview {{du_result}}

temp_tag := `date +%N`
host_no_proxy := "127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn"
proxy host="127.0.0.1" tmpfile=("/tmp/111nixdae.override.conf." + temp_tag):
  echo "[Service]" > {{tmpfile}}
  echo "Environment=\"https_proxy=socks5h://{{host}}:10809\"" >> {{tmpfile}}
  echo "Environment=\"no_proxy={{host_no_proxy}}\"" >> {{tmpfile}}
  sudo mkdir /run/systemd/system/nix-daemon.service.d/
  sudo mv -v {{tmpfile}} /run/systemd/system/nix-daemon.service.d/override.conf
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon

disable-commu:
  sed 's/https:\/\/nix-community.cachix.org//' < /etc/nix/nix.conf > /tmp/nix.conf
  sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.bak
  sudo mv /tmp/nix.conf /etc/nix/nix.conf
