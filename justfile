default: nixos

set shell := ["bash", "-euo", "pipefail", "-c"]

NOM_FLAGS := "--log-format internal-json -v |& nom --json"
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

# Evaluate every flake check, key eval assertions, and formatting precondition.
# Formatting: nixfmt 1.4 lacks --check; baseline accepted.  To tighten later,
# replace the placeholder with `nix fmt . && git diff --exit-code -- .` after
# confirming the whole repo passes nixfmt.
[group('build')]
chk *flags:
    nix flake check {{ flags }}
    bash ./tools/eval-assertions.sh .

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
# host/target/tagPrefix 从 deployTargets output 读取（hosts.nix 为唯一来源）。
[group('deploy')]
rebuild-pi *flags:
    just deploy-host nixos-pi4b {{ flags }}

# Deploy XPS13 and tag the successful revision.
[group('deploy')]
rebuild-xps *flags:
    just deploy-host nixos-xps13 {{ flags }}

# Deploy GTR7 and tag the successful revision.
[group('deploy')]
rebuild-gtr7 *flags:
    just deploy-host nixos-gtr7 {{ flags }}

# Internal unified deploy: clean-tree guard + remote switch + tag.
[private]
deploy-host host *flags:
    #!/usr/bin/env bash
    set -euo pipefail

    target="$(nix eval --raw .#deployTargets.{{ host }}.target)"
    tagprefix="$(nix eval --raw .#deployTargets.{{ host }}.tagPrefix)"

    # Clean-tree guard: refuse to deploy an unreproducible dirty worktree
    # unless ALLOW_DIRTY=1 (emergency path, no normal deploy tag).
    rev="$(ALLOW_DIRTY="${ALLOW_DIRTY:-0}" bash ./tools/deploy-guard.sh)"
    if [[ "$rev" == *-dirty ]]; then
      echo "warning: dirty deploy ({{ host }}); skipping normal tag" >&2
    fi

    nixos-rebuild switch --flake .{{ "#{{ host }}" }} --target-host "$target" {{ flags }} {{ NOM_FLAGS }}

    # Only tag when the switch succeeded and the tree still points at the
    # exact revision that was built.
    if [[ "$rev" != *-dirty ]]; then
      now="$(git rev-parse HEAD)"
      if [[ "$now" != "$rev" ]]; then
        echo "error: worktree moved during deploy ($now != $rev); not tagging" >&2
        exit 1
      fi
      just tag-deploy "$tagprefix"
    fi

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
# SOCKS 端口从 homelabEndpoints output 读取（os/homelab 为唯一来源）。
[group('maintenance')]
proxy host="127.0.0.1":
    #!/usr/bin/env bash
    set -euo pipefail

    port="$(nix eval --raw .#homelabEndpoints.proxy.socksPort)"
    tmpfile="$(mktemp /tmp/nix-daemon-proxy.XXXXXX)"
    trap 'rm -f "$tmpfile"' EXIT
    {
      echo "[Service]"
      echo "Environment=\"https_proxy=socks5h://{{ host }}:${port}\""
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

# Print the evaluated Nix version for GTR7.
[group('info')]
print-nix-ver:
    nix eval .#nixosConfigurations.nixos-gtr7.config.nix.package.version

# Show commits that changed flake.lock.
[group('info')]
update-history:
    git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" flake.lock
