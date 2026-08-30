default: nixos

set shell := ["bash", "-euo", "pipefail", "-c"]

NOM_FLAGS := "--log-format internal-json -v |& nom --json"
XPS_TARGET := "root@192.168.3.21"
GTR7_TARGET := "root@10.42.0.2" # direct connection
DU_RESULT := "/tmp/nix-du-result.svg"
HOST_NO_PROXY := "127.0.0.1,localhost,internal.domain,my-pi,mirrors.tuna.tsinghua.edu.cn,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn,gitee.com"

alias u := update
alias cont := continue
alias g := nixos-debug
alias pi := rebuild-pi
alias xps := rebuild-xps
alias gtr7 := rebuild-gtr7
alias hi := update-history

# Update pinned packages, then all flake inputs.
[group('build')]
update: update-bililiverecorder update-reasonix
    nix flake update --debug

# Update the pinned stable BililiveRecorder container tag.
[group('build')]
update-bililiverecorder:
    ./fool/bililiverecorder/update.py

# Update the pinned stable Reasonix CLI release.
[group('build')]
update-reasonix:
    ./fool/reasonix/update.py

# Evaluate every flake check.
[group('build')]
chk *flags:
    nix flake check {{ flags }}

# Activate the local host and show the system closure diff.
[group('build')]
nixos *flags:
    just snapshot-system
    sudo nixos-rebuild switch --flake . {{ flags }} {{ NOM_FLAGS }}
    just system-diff

# Retry local activation using the snapshot created by `nixos`.
[group('build')]
continue *flags:
    test -L .prev-system
    sudo nixos-rebuild switch --flake . {{ flags }} {{ NOM_FLAGS }}
    just system-diff

# Check and activate the local host with verbose logs.
[group('build')]
nixos-debug: chk
    sudo nixos-rebuild switch --flake . --verbose --show-trace --print-build-logs

[private]
snapshot-system:
    rm -f .prev-system
    ln -s /nix/var/nix/profiles/`readlink /nix/var/nix/profiles/system` .prev-system

[private]
system-diff:
    nvd diff .prev-system /nix/var/nix/profiles/system

# Check, deploy Pi and XPS sequentially; only run from GTR7.
[group('deploy')]
all:
    test "$(hostname)" = "nixos-gtr7"
    just chk
    just rebuild-pi
    just rebuild-xps

# Deploy Pi4B and tag the successful revision.
[group('deploy')]
rebuild-pi *flags:
    nixos-rebuild switch --flake .{{ "#nixos-pi4b" }} --target-host root@my-pi {{ flags }} {{ NOM_FLAGS }}
    just tag-deploy pi

# Deploy XPS13 and tag the successful revision.
[group('deploy')]
rebuild-xps *flags:
    nixos-rebuild switch --flake .{{ "#nixos-xps13" }} --target-host {{ XPS_TARGET }} {{ flags }} {{ NOM_FLAGS }}
    just tag-deploy xps

# Deploy GTR7 and tag the successful revision.
[group('deploy')]
rebuild-gtr7 *flags:
    nixos-rebuild switch --flake .{{ "#nixos-gtr7" }} --target-host {{ GTR7_TARGET }} {{ flags }} {{ NOM_FLAGS }}
    just tag-deploy gtr7

[private]
tag-deploy type:
    #!/usr/bin/env perl
    use strict;
    use warnings;

    my $latest = 0;
    foreach (split /\n/, qx/git tag -l '{{ type }}-r*'/) {
      $latest = $1 if /^{{ type }}-r(\d+)$/ && $latest < $1;
    }

    my $tag = '{{ type }}-r' . ($latest + 1);
    print "-- tagging '$tag'\n";
    exec 'git', 'tag', $tag or die "failed to create tag '$tag': $!\n";

# Build and run the Nixvim wrapper for fast Neovim config development.
[group('dev')]
nvim host="nixos-gtr7":
    #!/usr/bin/env bash
    set -euxo pipefail
    case "{{ host }}" in
      nixos-gtr7|nixos-xps13)
        user=fool
        ;;
      nixos-pi4b)
        user=pi
        ;;
      *)
        echo "unknown host: {{ host }}" >&2
        exit 2
        ;;
    esac
    nix build ".#nixosConfigurations.{{ host }}.config.home-manager.users.${user}.programs.nixvim.build.package"
    exec ./result/bin/nvim

# Link Zsh configuration files for fast development.
[group('dev')]
zsh:
    #!/usr/bin/env bash
    set -euxo pipefail
    cd ./fool/zsh
    cp -lb zshrc zshenv p10k.zsh ~/.lintd/zsh/

# Create a Home Manager module skeleton and open it.
[group('dev')]
add-app name:
    mkdir fool/{{ name }}
    nvr -p fool/{{ name }}/default.nix fool/default.nix

# Prefetch a GitHub flake through proxychains.
[group('dev')]
test:
    proxychains4 nix flake prefetch github:numtide/flake-utils

# Run recorded post-upgrade fixes.
[group('maintenance')]
fix: fix-alsa-store

# Persist current ALSA hardware parameters.
[group('maintenance')]
fix-alsa-store:
    sudo alsactl store

# Render and open the Nix store size graph.
[group('maintenance')]
du:
    nix-du -s=500MB | dot -Tsvg > {{ DU_RESULT }}
    gwenview {{ DU_RESULT }}

# Configure a temporary SOCKS5 proxy for nix-daemon.
[group('maintenance')]
proxy host="127.0.0.1":
    #!/usr/bin/env bash
    set -euo pipefail

    tmpfile="$(mktemp /tmp/nix-daemon-proxy.XXXXXX)"
    trap 'rm -f "$tmpfile"' EXIT
    {
      echo "[Service]"
      echo 'Environment="https_proxy=socks5h://{{ host }}:10809"'
      echo 'Environment="no_proxy={{ HOST_NO_PROXY }}"'
    } > "$tmpfile"
    sudo install -Dm0644 "$tmpfile" /run/systemd/system/nix-daemon.service.d/override.conf
    just daemon-restart

# Remove the temporary nix-daemon proxy.
[group('maintenance')]
no-proxy:
    sudo rm -f /run/systemd/system/nix-daemon.service.d/override.conf
    just daemon-restart

# Print nix-daemon environment variables.
[group('maintenance')]
daemon-env:
    sudo cat /proc/`pidof nix-daemon | awk '{print $1}'`/environ | tr '\0' '\n'

[private]
daemon-restart:
    sudo systemctl daemon-reload
    sudo systemctl restart nix-daemon

# Temporarily remove community and mirror substituters from nix.conf.
[group('maintenance')]
disable-commu:
    #!/usr/bin/env bash
    set -euo pipefail

    config=/etc/nix/nix.conf
    backup=/etc/nix/nix.conf.bak
    test ! -e "$backup"
    tmpfile="$(mktemp /tmp/nix-conf.XXXXXX)"
    trap 'rm -f "$tmpfile"' EXIT
    sed 's|https://nix-community.cachix.org||' "$config" > "$tmpfile"
    perl -pi -e 's/https:\/\/mirrors?\.\S+//g' "$tmpfile"
    sudo cp -a "$config" "$backup"
    sudo install -m0644 "$tmpfile" "$config"
    just daemon-restart

# Restore nix.conf saved by `disable-commu`.
[group('maintenance')]
cfg-rollback:
    test -e /etc/nix/nix.conf.bak
    sudo mv -f /etc/nix/nix.conf.bak /etc/nix/nix.conf
    just daemon-restart

# Print the evaluated Nix version for GTR7.
[group('info')]
print-nix-ver:
    nix eval .#nixosConfigurations.nixos-gtr7.config.nix.package.version

# Show commits that changed flake.lock.
[group('info')]
update-history:
    git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" flake.lock
