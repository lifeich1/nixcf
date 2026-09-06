---
name: nixcf-service-firewall
description: Add, review, or refactor network-facing NixOS and Home Manager services in the nixcf repository while preserving service state and assigning each firewall rule to one owner. Use for firewall policy, listen addresses, ports, service users, systemd hardening, OCI containers, and service options involving Gitea, Attic, Hobob, Syncthing, vlmcsd, Bilibili Live Recorder, VirtualBox or desktop networking, Xray, OpenSSH, and KDE Connect.
---

# Nixcf Service and Firewall

Change service and network boundaries from current evidence. Keep local configuration work separate from live firewall changes, restarts, deployment, and data migration.

## Guardrails

- Treat source and `flake.lock` as current truth. Treat README files as navigation and dated refactor plans as historical recommendations to revalidate.
- Never inspect, decrypt, print, copy, or synthesize secret values. Read Agenix declarations and runtime paths only.
- Treat `host/common.nix` and the credential candidates identified by the Agenix reference as opaque while `.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh` fails. Do not open them directly or use a content-producing search.
- Run that source-safety gate before every repo-consuming Nix evaluation, build, check, lock, activation, or deployment command. Stop on a nonzero result; a narrower attribute does not bypass the risk of copying tracked source into `/nix/store`.
- Never deploy, restart or stop a service, migrate or delete data, alter a live firewall, pull a live container image, update inputs, commit, or tag unless the user explicitly authorizes that exact action.
- Do not edit `hardware-configuration.nix`, `system.stateVersion`, or `home.stateVersion` for a service change.
- For review or diagnosis requests, remain read-only. Implement only when the user requests a change.
- Do not claim a listener, migration, backup, deployment, or recovery path was verified from Nix evaluation alone.

## Read the minimum context

1. Read the repository `README.md` and `flake.nix`.
2. Identify every affected host and Home Manager profile. Read their `readme.md` and entry module.
3. Read the service directory's `readme.md`, implementation, parent `os/readme.md` or `fool/readme.md`, and relevant aggregator.
4. Read `os/firewall`, upstream option usage in source, and any direct host firewall rules that overlap.
5. Read Agenix declarations without opening `.age` payloads when the service consumes credentials. Run the source-safety gate before following any route through `host/common.nix` or known credential candidates.
6. Read [references/source-routing.md](references/source-routing.md) for repository-specific routing and links. Open only the dated plans relevant to the requested change and only sources the gate permits.

Use `rg` and `rg --files` to locate options and consumers. Do not scan unrelated modules.

## Stop for material decisions

Ask the user interactively before selecting among materially different outcomes when any of these remain ambiguous:

- whether a listener is loopback-only, LAN-accessible, or reachable from wider networks, including the allowed client sources;
- whether existing state must move, which backup and restore test is acceptable, or whether a format upgrade can occur;
- whether a service truly requires root, a privileged port, host networking, device access, or Linux capabilities;
- which immutable container digest is approved and whether it is available for every enabled architecture, especially `aarch64-linux` on Pi;
- which independent recovery route is available before tightening SSH or firewall access on a remote host.

Present the current evidence, the recommended choice, and its impact. Continue safe source inspection while waiting, but do not encode an arbitrary answer.

## Workflow

### 1. Establish scope and current behavior

Build a host/service matrix containing:

- configuration name, architecture, user, Home profile, and enablement source;
- service module, package or image, state paths, service identity, and secret runtime path;
- declared bind address, TCP/UDP port, port mapping, and current firewall owner;
- dependencies on proxy, cache, DNS name, LAN address, or another service.

Distinguish configured intent from live fact. Before tightening exposure, require an actual listener inventory from user-provided evidence or an explicitly authorized read-only check. Record at least protocol, local address, port, process/unit, expected clients, and whether the listener is temporary. Do not record payloads or credentials.

### 2. Choose ownership

- Put reusable NixOS service implementation in `os/<service>/`; keep `host/<hostname>/` to imports, enablement, and host-specific values.
- Put reusable Home Manager container or user-service implementation in `fool/<service>/`; keep `home/<profile>/` to enablement and personal values.
- Let the service module own its bind, typed port, and firewall rule. Prefer an upstream NixOS option when it already provides the rule, as with OpenSSH, Syncthing, or KDE Connect.
- Ensure exactly one owner for each rule. Remove duplicated host or generic-firewall rules only after the replacement evaluates equivalently.
- Do not make a Home Manager module silently own the system firewall. For a user container, expose bind/host-port/access intent in the user module and route any required NixOS firewall rule through one explicit system owner.
- Keep broad firewall policy separate from application-named options. Do not introduce generic switches such as `serve-<application>`.

### 3. Design typed, safe options

Use typed options for every configurable boundary:

- use `lib.types.port` for host and service ports;
- expose a listen or bind address separately from a port;
- use `openFirewall` as an explicit boolean, normally defaulting to false;
- type package, path, enum, list, and attribute options rather than accepting arbitrary strings;
- assert invalid combinations such as opening a port for a loopback-only listener or enabling a service without its required user/data path.

Generate port-mapping strings inside the module. Do not use the presence of a port mapping as proof that the firewall should be open. Keep endpoint, migration proxy, SOCKS proxy, and cache roles distinct even when they currently share a host.

### 4. Migrate firewall ownership without lockout

1. Inventory current declared rules, evaluated rules, and actual listeners.
2. Add service-owned rules while preserving the existing broad rule.
3. Compare the evaluated TCP/UDP ports and ranges before and after ownership migration.
4. Remove duplicate application or host rules in a behavior-preserving change.
5. Tighten broad ranges in a separate change only after the user decides exposure and recovery paths.
6. Stage live rollout by host: preserve a prior generation, change one host, test access and application health, then continue only after success.

Never combine a default-deny transition with unrelated option renames, image changes, or state migration. A local patch may prepare these stages, but live execution needs separate authority.

### 5. Minimize service privilege

- Prefer a dedicated system user/group or a compatible `DynamicUser` design.
- Declare state, cache, runtime, log, and configuration directories through NixOS/systemd facilities where possible; set ownership deliberately.
- Use `lib.getExe` or an explicit packaged executable and declare network ordering only when the program needs it.
- Add systemd hardening incrementally after checking program behavior. Consider `NoNewPrivileges`, filesystem protections, private temporary storage, device restrictions, capability bounds, and writable path allowlists.
- Do not guess away root or add broad capabilities. Ask for evidence when the program needs privileged ports, devices, arbitrary paths, or host networking, then grant only the minimum.

### 6. Wire secrets at runtime

- Use Agenix runtime files or systemd credentials; do not interpolate secret content into Nix strings, derivations, generated environment files, documentation, logs, or commands.
- Match owner, group, and mode to the service identity. Verify that the service receives the runtime path, not a copied store path.
- When changing Attic, check the coupled substituter, public key, netrc, client, and server configuration without exposing credentials.
- Route credential rotation or recipient changes through the repository's Agenix skill and corresponding dated credential plan.

### 7. Preserve state and containers

For Gitea, Attic, Hobob, Syncthing, recorders, and any other stateful service:

1. Identify current data, database, repository, LFS, cache, configuration, and recording paths from source and authorized runtime evidence.
2. Keep paths, users, folder IDs, sync direction, retention, chunking, and formats unchanged during structural refactors.
3. Define a backup, integrity check, restore test, cutover, and rollback before any migration.
4. Require explicit authority before stopping writers or copying data. Retain the old data read-only until acceptance; never let old and new units write it simultaneously.

For containers, expose image, digest, bind/listen address, host/container ports, data directory, restart policy, and access policy. Require an immutable approved digest, inspect manifest architecture support, and validate Pi images on `aarch64-linux`. Separate image changes from data-format or directory migrations.

### 8. Apply service-specific checks

- **Attic:** Preserve existing storage and chunking unless explicitly changing them; coordinate runtime credentials, cache endpoint, retention, and firewall ownership.
- **Gitea:** Preserve database, repository, LFS, domain, registration, and clone behavior;
  keep migration proxy separate from public serving. The former
  `mailer.SENDMAIL_PATH = "/fix-merged-wait-deploy"` workaround was removed (evaluated
  2025-09-07: the upstream module owns that option and derives a safe default while mailer
  is disabled) — do not reintroduce placeholder values; re-evaluate upstream options before
  adding or retaining workarounds.
- **Hobob:** The live resource root is `/home/pi/hub/hobob` (2025-09-07 inventory:
  `/opt/hobob` only holds symlinks to it plus a writable `.cache`; the service ran as root).
  Target a dedicated `hobob` system user, explicit `dataDir` at `/home/pi/hub/hobob`
  (never move resources to `/var/lib/hobob`), `StateDirectory=hobob` for writable state,
  and verify which paths the program actually writes before adding hardening or dropping
  root. Require a decision for any remaining root or capability need.
- **Syncthing:** Use the upstream `services.syncthing.openDefaultPorts` option (TCP/UDP
  22000 + UDP 21027 discovery) through the wrapper's `fool.syncthing.openFirewall`
  passthrough. Personal folders/devices topology lives in `os/syncthing/topology.nix`,
  imported explicitly by GTR7/XPS13 hosts. Preserve device IDs, folder IDs, paths,
  receive-only direction, and override semantics while separating reusable wrapper from
  personal topology.
- **vlmcsd and recorders:** vlmcsd uses the NixOS OCI container declaration only (the
  `cmd` branch and `invokeType` were removed); the module owns its `openFirewall` rule.
  Generate mappings from typed ports, pin images by digest, verify architecture, and keep
  image and data changes separate. Validate on the actual runtime host: vlmcsd on
  Pi (`aarch64-linux`), bililiverecorder on GTR7 (`x86_64-linux`, Home Manager) — do not
  merge the two verification paths into one "Pi/aarch64" step.
- **VirtualBox and desktop networking:** `fool.virtualbox.users` derives `vboxusers`
  membership in the module; hosts no longer hand-write that group. Desktop stacks are
  composable `fool.collections` profiles — `desktop`, `audio`, `pro-audio` — and both
  GTR7 and XPS13 enable pro-audio (JACK + realtime loginLimits; 2025-09-07 decision).
  Review bridge/host-only interfaces, user groups, devices, KDE Connect, professional-audio
  ports, and application ownership independently; do not infer exposure merely from
  enablement.
- **Xray:** Determine listener/firewall needs from safe runtime inventory or sanitized configuration facts; never open the encrypted configuration. Loopback-only listeners need no inbound rule.
- **OpenSSH and KDE Connect:** Prefer upstream firewall controls and verify their evaluated
  port/range effects. KDE Connect has no separate firewall option: enabling
  `programs.kdeconnect` automatically opens TCP/UDP 1714-1764, owned solely by that upstream
  module via the plasma/desktop collection. Require a recovery route before restricting
  remote SSH access.

### 9. Validate local configuration

- Update the affected module or directory `readme.md` so options, ownership, and enablement match source.
- Run `git diff --check`.
- Before any Nix command, run `.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh`; if blocked, skip Nix validation and report the path/category-only result.
- For Nix changes, run `just chk` only after the gate succeeds.
- Evaluate or build each affected host, including `nixos-pi4b` for `aarch64-linux` changes, only after the gate succeeds.
- Inspect final evaluated `allowedTCPPorts`, `allowedUDPPorts`, and ranges to detect duplicates or unexpected broad access.
- Report any live inventory, architecture manifest, backup/restore, service health, or connectivity check that remains unverified.

Do not run deployment recipes as validation. Hand deployment to the dedicated deployment workflow only after explicit authorization.

## Report the result

Lead with the ownership and exposure outcome. List affected hosts, decisions made, state/secret safeguards, files changed, validation performed, and unresolved live checks. Clearly distinguish source evaluation from live verification and give a staged rollback plan for any future rollout.
