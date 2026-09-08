#!/usr/bin/env bash
# Key eval assertions for the three hosts.
# Runs from the flake root; fails on the first mismatch.
set -euo pipefail

flake="${1:-.}"
fail=0

# Compare the quoted nix eval output against expected (unquoted) value.
check() {
  local host="$1" attr="$2" expected="$3"
  local actual
  actual="$(nix eval "$flake#nixosConfigurations.$host.$attr" 2>/dev/null | tr -d '"')" || {
    echo "FAIL $host $attr: eval error (expected '$expected')"
    fail=1
    return
  }
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL $host $attr: expected '$expected' got '$actual'"
    fail=1
  else
    echo "ok   $host $attr = $actual"
  fi
}

# Gateway eval — these guarantee the whole config evaluates
for host in nixos-gtr7 nixos-xps13 nixos-pi4b; do
  nix eval "$flake#nixosConfigurations.$host.config.system.build.toplevel.drvPath" >/dev/null 2>&1 || {
    echo "FAIL $host: toplevel eval failed"; fail=1
  }
done

# Architecture / hostname / username / boot loader
check nixos-gtr7 config.nixpkgs.hostPlatform.system x86_64-linux
check nixos-gtr7 config.networking.hostName nixos-gtr7
check nixos-gtr7 config.system.boot.loader.id systemd-boot
check nixos-xps13 config.networking.hostName nixos-xps13
check nixos-xps13 config.system.boot.loader.id systemd-boot
check nixos-pi4b config.networking.hostName nixos-pi4b
check nixos-pi4b config.system.boot.loader.id generic-extlinux-compatible

# Home Manager user
check nixos-gtr7 "config.home-manager.users.fool.home.username" fool
check nixos-xps13 "config.home-manager.users.fool.home.username" fool
check nixos-pi4b "config.home-manager.users.pi.home.username" pi

# Firewall (enabled)
check nixos-gtr7 config.networking.firewall.enable true
check nixos-xps13 config.networking.firewall.enable true
check nixos-pi4b config.networking.firewall.enable true

# External package availability (all hosts have nvim)
check nixos-gtr7 "config.home-manager.users.fool.programs.nixvim.build.package.name" nixvim
check nixos-xps13 "config.home-manager.users.fool.programs.nixvim.build.package.name" nixvim
check nixos-pi4b "config.home-manager.users.pi.programs.nixvim.build.package.name" nixvim

echo "---"
if (( fail )); then
  echo "some key eval assertions failed"
  exit 1
fi
echo "all key eval assertions passed"