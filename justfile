default: nixos

chk:
  nix flake check

nom_flag := "--log-format internal-json -v |& nom --json"

nixos *flags:
  sudo nixos-rebuild switch --flake . {{flags}} {{nom_flag}}

alias g := nixos-debug
alias pi := rebuild-pi

nixos-debug: chk
  sudo nixos-rebuild switch --flake . --verbose --show-trace --print-build-logs

colmena-pi *flags:
  colmena apply --on pi4b {{flags}}

rebuild-pi *flags:
  nixos-rebuild switch --flake .{{"#nixos-pi4b"}} --target-host root@my-pi {{flags}} {{nom_flag}}

xps *flags:
  colmena apply --on xps {{flags}}

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
