# Repository map and safe checks

Read this reference when a task touches secrets, Xray, login passwords, Attic, recipients, migration, or validation. Verify all relationships against current source.

## Credential map

| Layer | Relevant source | Inspect for |
|---|---|---|
| Flake assembly | `flake.nix` | Host, username, Home profile, Agenix module import, Pi-only Attic module import |
| Agenix declarations | `secrets/default.nix` | Secret names, encrypted file references, identity paths, runtime path, owner/group/mode, password consumer |
| Recipient mapping | `secrets/secrets.nix` | Public-key identities and payload-to-recipient sets; do not reproduce key bodies |
| Encrypted payloads | `secrets/*.age` | Names and filesystem metadata only; never contents or content diffs |
| Xray system consumer | `secrets/default.nix`, affected host configuration | Runtime path and enablement only; never open the encrypted configuration |
| User passwords | `secrets/default.nix`, affected host configuration | Host-selected logical password name and `hashedPasswordFile` consumer |
| Attic client | `fool/attic/default.nix`, `home/pc/default.nix` | Client service enablement, runtime config reference, cache name |
| Nix cache client | `os/nix` (`nix.settings.netrc-file`) | Reference the runtime path `/run/agenix/attic-netrc`; never display netrc contents |
| Attic server | `os/atticd/default.nix`, `host/nixos-pi4b/configuration.nix` | `environmentFile`, service identity, port and enablement |
| Legacy/suspicious files | `os/atticd/atticd.env`, `host/nixos-pi4b/atticd.env`, `fool/attic/attic-client.toml` | Filename, tracking state and actual reference chain only; never contents |

The Attic path crosses Home Manager, shared NixOS cache configuration, the system service module, and the Pi host. Check all four layers together. A client token, server token, cache public key, and SSH/Agenix recipient key are different credential types; never conflate them.

## Source-safety gate

Run this bundled gate before opening a potential credential source and before any repo-consuming `nix`, `nixos-rebuild`, or `just` command:

```sh
.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh
```

The gate emits only fixed categories and repository paths. It never prints matched lines or values. A nonzero result means:

- do not open any reported credential-bearing source;
- do not run flake evaluation, build, check, lock mutation, activation, or deployment;
- continue only with filename/status metadata, non-secret sources, and a user-operated or separately reviewed remediation path.

The gate checks known blockers; success is not proof that the repository contains no other secret. Continue following the no-plaintext rules after it passes.

## Safe discovery commands

Run from the repository root. These commands return paths, names, status, or file metadata—not payload content.

```sh
git status --short
.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh
git ls-files 'secrets/*' 'os/atticd/*' 'host/nixos-pi4b/*' 'fool/attic/*'
find secrets -maxdepth 1 -type f -printf '%f\n' | sort
stat -c '%A %U:%G %n' secrets/*.age
rg -l --glob '!*.age' --glob '!*.env' --glob '!*.toml' 'age\.secrets|hashedPasswordFile|settingsFile|netrc-file|environmentFile|fool\.attic|fool\.atticd' flake.nix secrets host home os fool
git diff --name-status -- secrets host home os fool flake.nix
git diff --check -- path/to/confirmed-non-secret-file.nix
```

Replace the last placeholder only with explicit changed files already confirmed not to contain credentials. Do not replace `rg -l` with content-producing `rg`, and do not run `git diff`, `git diff --check`, `git show`, `git log -p`, or `git blame` on secret-bearing paths. If a filename itself is sensitive, omit it from user-facing output.

## Safe evaluation examples

Evaluate only known structural attributes and only after the source-safety gate succeeds. Never evaluate a `.text`, credential, token, environment contents, or an entire config subtree.

```sh
.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh
# Continue only after PASS.
nix eval --raw '.#nixosConfigurations.nixos-gtr7.config.age.secrets.xray-config.path'
nix eval --raw '.#nixosConfigurations.nixos-xps13.config.services.xray.settingsFile'
nix eval --raw '.#nixosConfigurations.nixos-pi4b.config.services.atticd.environmentFile'
just chk
```

Never bypass a blocked gate with a narrower Nix attribute: a path flake may copy tracked source before evaluating that attribute. Adjust the host or logical name only after safe source establishes it. Structural evaluation may prove two paths agree; it does not prove that credential material is valid or that a live service accepted it.

## Rotation and remediation handoff

For a recipient change or rotation, have the user perform the Agenix edit/rekey in a trusted local interactive session. Ask them to report only whether it succeeded and which logical secret was handled. Then validate names, mappings, working-tree status, and Nix evaluation without inspecting the payload.

For suspected exposure, separate these actions and obtain authorization for each:

1. remove plaintext wiring from the current tree and runtime generation;
2. rotate/revoke the actual credential;
3. verify and restart affected consumers;
4. assess existing Nix-store paths, logs, caches, backups, and clones;
5. coordinate a Git-history rewrite and force update if still required.

Never claim remediation is complete after only the first action.
