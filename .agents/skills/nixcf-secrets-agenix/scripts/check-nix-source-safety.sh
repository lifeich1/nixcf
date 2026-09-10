#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' 'BLOCKED: run this gate inside the nixcf Git repository.' >&2
  exit 2
}
cd "$repo_root"

if ! command -v rg >/dev/null 2>&1; then
  printf '%s\n' 'BLOCKED: rg is required for non-output structural checks.' >&2
  exit 2
fi

blocked=0

tracked_plaintext_candidates=(
  'os/atticd/atticd.env'
  'host/nixos-pi4b/atticd.env'
  'fool/attic/attic-client.toml'
)

for candidate in "${tracked_plaintext_candidates[@]}"; do
  if [[ -e "$candidate" ]] && git ls-files --error-unmatch -- "$candidate" >/dev/null 2>&1; then
    printf 'BLOCKED: tracked credential-bearing source remains: %s\n' "$candidate" >&2
    blocked=1
  fi
done

# Inspect fixed structural markers without emitting matching lines or values.
# host/common.nix was removed by the credential refactor; keep this regression
# guard so the inline-netrc pattern cannot silently return under that path.
if [[ -f host/common.nix ]] \
  && rg -q -- 'environment\.etc\.[^[:space:]]*netrc[^[:space:]]*\.text[[:space:]]*=' host/common.nix; then
  printf '%s\n' 'BLOCKED: inline generated-file text in host/common.nix requires credential remediation.' >&2
  blocked=1
fi

if [[ -f os/atticd/default.nix ]] \
  && rg -q -- 'source[[:space:]]*=[[:space:]]*\./atticd\.env' os/atticd/default.nix; then
  printf '%s\n' 'BLOCKED: os/atticd still imports a plaintext credential candidate.' >&2
  blocked=1
fi

if [[ -f fool/attic/default.nix ]] \
  && rg -q -- 'source[[:space:]]*=[[:space:]]*\./attic-client\.toml' fool/attic/default.nix; then
  printf '%s\n' 'BLOCKED: fool/attic still imports a plaintext credential candidate.' >&2
  blocked=1
fi

if ((blocked)); then
  printf '%s\n' 'BLOCKED: do not run repo-consuming Nix eval, build, check, lock, activation, or deployment commands.' >&2
  exit 1
fi

printf '%s\n' 'PASS: known nixcf plaintext-source blockers are absent; continue normal secret-safe review.'
