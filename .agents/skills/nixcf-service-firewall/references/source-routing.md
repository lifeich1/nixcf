# Source routing for service and firewall work

Use this file to find current sources; do not treat the observations below as permanent configuration facts. Re-read every linked source before changing it.

## Repository and hosts

| Concern | Current source |
|---|---|
| Host registry, architecture, Home profile, module assembly | [`flake.nix`](../../../flake.nix) |
| Shared Nix/cache, netrc, Xray wiring | [`os/nix`](../../../os/nix) and [`secrets/default.nix`](../../../secrets/default.nix) (`host/common.nix` was removed by the credential refactor) |
| GTR7 enablement | [`host/nixos-gtr7/configuration.nix`](../../../host/nixos-gtr7/configuration.nix) and its [`readme.md`](../../../host/nixos-gtr7/readme.md) |
| XPS13 enablement | [`host/nixos-xps13/configuration.nix`](../../../host/nixos-xps13/configuration.nix) and its [`readme.md`](../../../host/nixos-xps13/readme.md) |
| Pi enablement | [`host/nixos-pi4b/configuration.nix`](../../../host/nixos-pi4b/configuration.nix) and its [`readme.md`](../../../host/nixos-pi4b/readme.md) |
| GTR7 user containers | [`home/pc/default.nix`](../../../home/pc/default.nix) and its [`readme.md`](../../../home/pc/readme.md) |

Host mapping at the time this skill was written:

| Configuration | Home profile | User | Architecture |
|---|---|---|---|
| `nixos-gtr7` | `home/pc` | `fool` | `x86_64-linux` |
| `nixos-xps13` | `home/lightpad` | `fool` | `x86_64-linux` |
| `nixos-pi4b` | `home/micro-srv` | `pi` | `aarch64-linux` |

Confirm this table against `flake.nix` each time.

## Service routing

| Service or boundary | Implementation and related source | Recheck before editing |
|---|---|---|
| Generic firewall | [`os/firewall`](../../../os/firewall) | broad ranges, application-named options, direct host rules |
| Attic daemon | [`os/atticd`](../../../os/atticd), [`fool/attic`](../../../fool/attic), [`os/nix`](../../../os/nix) | special flake import, listen address, state/chunking, runtime secret, cache coupling |
| Gitea | [`os/gitea`](../../../os/gitea) | public port owner, domain, migration proxy, registration, state/LFS paths |
| Hobob | [`os/hobob`](../../../os/hobob) | system versus user namespace, package injected at the enablement site, root, `dataDir`, state migration |
| Syncthing | [`os/syncthing`](../../../os/syncthing) | upstream firewall options, personal topology, IDs, receive-only paths, override flags |
| vlmcsd | [`os/vlmcsd`](../../../os/vlmcsd) | backend branches, image tag/digest, port typing, Pi architecture |
| Bilibili Live Recorder | [`fool/bililiverecorder`](../../../fool/bililiverecorder) | Home Manager container boundary, image, bind/ports, recording path, system firewall owner |
| VirtualBox | [`os/virtualbox`](../../../os/virtualbox) | host/guest split, group ownership, KVM and network interface behavior |
| Desktop/KDE Connect | [`os/plasma`](../../../os/plasma), [`os/collections`](../../../os/collections) | upstream firewall effects, desktop/audio ownership, host differences |
| Xray | [`secrets/default.nix`](../../../secrets/default.nix) and the affected host configuration | runtime secret path, safe listener evidence (the imperative `fool/xray` installer was removed) |
| OpenSSH | [`os/default.nix`](../../../os/default.nix) and target host | upstream option ownership, access policy, recovery path |

Run the source-safety gate before opening any routed source or invoking Nix:

```console
.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh
```

While it is blocked, do not open any reported credential candidate. Search only permitted sources for additional owners before deciding:

```console
rg -n --glob '!*.env' --glob '!*.toml' 'openFirewall|allowedTCP|allowedUDP|PortRanges|ports =|listen|hostPort|containerPort' os host home fool
rg -n --glob '!*.env' --glob '!*.toml' 'fool\.(firewall|gitea|atticd|hobob|syncthing|vlmcsd|virtualbox)|services\.(xray|openssh)' os host home fool
```

Do not open `.age` files or print environment/token files while tracing dependencies.

## Dated references

- [`.plans/refactor-audit.md`](.plans/refactor-audit.md) is the 2026-08-30 audit baseline.
- [`.plans/refactor-plan-01-credentials.md`](.plans/refactor-plan-01-credentials.md) covers runtime credentials and Agenix sequencing.
- [`.plans/refactor-plan-03-host-endpoints.md`](.plans/refactor-plan-03-host-endpoints.md) covers host registry, endpoint, proxy, cache, and package ownership that services consume.
- [`.plans/refactor-plan-04-firewall-services.md`](.plans/refactor-plan-04-firewall-services.md) proposes the firewall/service migration order, validation, and rollback.
- [`.plans/refactor-plan-05-home-operations.md`](.plans/refactor-plan-05-home-operations.md) covers Home Manager container and operational follow-up.

Use these documents to recover rationale and known risks. Verify every stated path, option, enablement, and dependency against current source and `flake.lock`; do not automatically execute their sequence.

## Evidence to retain in the handoff

For each affected host, report:

1. Current and proposed owner of each TCP/UDP rule.
2. Configured bind versus observed listener, with evidence source.
3. Service identity, writable/state paths, and runtime secret path without secret content.
4. Package or immutable image identity and supported architecture.
5. Backup, restore, staged rollout, and recovery status.
6. Local evaluation/build status separately from live health and connectivity status.
