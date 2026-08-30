# Deployment reference

Use this file as a checklist and navigation aid. Re-read `flake.nix`, `justfile`, and the target readmes before every operation; they are authoritative and this snapshot can become stale.

## Current host registry snapshot

| Flake output | Architecture | User | Device | Home profile | Deployment entry | Current target source |
|---|---|---|---|---|---|---|
| `nixos-gtr7` | `x86_64-linux` | `fool` | `gtr7` | `home/pc` | `just gtr7` | `GTR7_TARGET` in `justfile` |
| `nixos-xps13` | `x86_64-linux` | `fool` | `xps13` | `home/lightpad` | `just xps` | `XPS_TARGET` in `justfile` |
| `nixos-pi4b` | `aarch64-linux` | `pi` | `pi4b` | `home/micro-srv` | `just pi` | literal target in `rebuild-pi` |

Resolve the address and remote login from the recipe itself. Do not substitute the Home Manager user for the remote deployment login: the current remote recipes use a privileged deployment login even where the configured normal user differs.

## Current recipe semantics

| Recipe | Current high-level behavior | Check included | Tag included |
|---|---|---|---|
| `just chk` | Evaluate all flake checks | It is the check | No |
| `just nixos` | Snapshot local system profile, switch local flake, show closure diff | No | No |
| `just continue` | Retry local switch using an existing snapshot, show diff | No | No |
| `just nixos-debug` | Run `chk`, then verbose local switch | Yes | No |
| `just pi` | Switch `nixos-pi4b` remotely | No | `pi-r<N>` after switch |
| `just xps` | Switch `nixos-xps13` remotely | No | `xps-r<N>` after switch |
| `just gtr7` | Switch `nixos-gtr7` remotely | No | `gtr7-r<N>` after switch |
| `just all` | From GTR7 only: check, then deploy Pi and XPS in that order | Yes, once | One tag per successful child recipe |

`tag-deploy` finds the largest matching numeric suffix and creates the next lightweight Git tag. A successful switch followed by a failed tag is a partial result, not a failed switch. A tag records `HEAD`, which may not represent dirty working-tree content used by a path flake.

## Preflight evidence

Collect without opening secret contents:

- repository path, branch/detached state, `HEAD`, and upstream when relevant;
- tracked and untracked working-tree status;
- filename-only staged and unstaged changes under `flake.lock` and `secrets/`;
- exact selected registry entry and recipe expansion;
- `just chk` result against an unchanged source state;
- current system profile target/generation for every selected host;
- recovery channel, maintenance window, and expected health checks.

For changes touching remote access, firewall, boot, storage, networking, users, SSH, secrets, Nix substituters, public keys, netrc, or the Pi Attic service, require an independent recovery route and inspect the coupled modules named by repository instructions.

## Result states

Keep these events separate:

```text
source identified -> checked/built -> switched -> reconnected -> health verified -> tag verified
```

A later failure does not erase an earlier success. In particular, report “deployed but untagged” when the switch succeeded and the recipe's tag stage failed, and report “tagged but unhealthy” when the tag exists but live verification fails. Stop the sequence and obtain a rollback decision in either unsafe partial state.
