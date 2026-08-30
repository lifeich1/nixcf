---
name: nixcf-module-change
description: Implement and review scoped NixOS or Home Manager module changes in the nixcf repository. Use when adding a reusable module, changing a `fool.*` option, wiring imports, enabling a feature for a host or Home profile, moving shared logic out of host/profile files, or updating the corresponding module documentation.
---

# nixcf Module Change

Route each change through the repository's host/profile/module graph, keep machine selection separate from reusable implementation, and validate every affected configuration.

## Inspect Before Editing

1. Work from the repository root and inspect `git status --short`. Preserve unrelated user changes and do not reformat or revert them.
2. Read `README.md` and `flake.nix`. Derive the current host names, architectures, usernames, Home profiles, module arguments, and import graph from source rather than memory.
3. Before opening `host/common.nix` or another potential credential source, run `skill/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh`. If blocked, treat every reported path as opaque and continue only with path/status metadata and permitted sources.
4. Read the `readme.md` in the target directory and its parent. Open only the target host/profile and modules implicated by the request and permitted by the source-safety gate.
5. Trace the option definition, every enablement site, and any shared dependency before deciding where to edit. When changing proxy behavior, inspect both the user and system definitions of `fool.proxy` only when the gate permits their sources; otherwise report the blocked dependency.
6. Identify the affected `nixosConfigurations` and architectures. Pay particular attention to external packages and overlays reachable by `aarch64-linux` hosts.

Ask the user only when the target host/profile or the intended sharing boundary cannot be inferred and the alternatives would materially change behavior on different machines. Otherwise, make the narrowest source-backed assumption and state it.

## Route the Change

| Concern | Location | Rule |
|---|---|---|
| Machine-specific system or hardware selection | `host/<hostname>/` | Keep only host differences and system feature switches here. |
| Profile-specific user feature selection | `home/<profile>/` | Enable Home Manager features here; do not implement reusable modules here. |
| Reusable NixOS behavior | `os/<name>/` | Define system options and guarded configuration here. |
| Reusable Home Manager behavior | `fool/<name>/` | Put options under the `fool.*` namespace and guard configuration here. |
| Packages exposed from flake inputs | `fool/overlays/` | Confirm every affected architecture has the required output. |

Move behavior used by multiple hosts or profiles into `os/` or `fool/` instead of copying it. Keep a one-host implementation local only when it is intrinsically machine-specific.

## Implement the Module

1. Add or update `default.nix` in the selected reusable module directory.
2. Declare an explicit option under `fool.<name>` and use `lib.mkIf` or `lib.mkMerge` to make opt-in behavior clear. Reuse existing repository conventions instead of introducing a second namespace or enablement pattern.
3. Import a new reusable module from `os/default.nix` or `fool/default.nix`. Preserve explicit exceptional imports in `flake.nix` unless the task specifically requires changing that architecture.
4. Enable the option from the relevant `host/<hostname>/configuration.nix`, `home/<profile>/default.nix`, or an existing shared profile such as `home/desktop-common.nix`.
5. Update the new module's `readme.md` and every affected parent or profile `readme.md` whose routing, options, dependencies, or enabled feature list changed. Describe current source behavior, not intended future work.
6. Re-read the complete diff to catch duplicate imports, unconditional configuration, misplaced host choices, and accidental edits outside scope.

## Respect Guardrails

- Do not modify `hardware-configuration.nix` unless the request explicitly concerns hardware changes.
- Do not change `system.stateVersion` or `home.stateVersion` as part of a module or input upgrade.
- Do not update flake inputs or `flake.lock`, deploy, create tags, or commit unless the user explicitly authorizes that action.
- Do not decrypt, print, copy, or move secret plaintext. If a module needs a credential, use the repository's Agenix declarations and runtime paths without exposing values.
- Treat `host/common.nix` cache settings and the Pi Attic service as coupled. While the source-safety gate is blocked, keep `host/common.nix` opaque and do not attempt to inspect its netrc producer; report that the coupled change cannot yet be completed safely.

## Validate and Report

Run validation in proportion to the change:

1. Run `git diff --check` for every change, including documentation-only work.
2. Before any repo-consuming Nix command, run `skill/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh`. Stop and report its path/category-only output if blocked; do not open reported sources or bypass it with a narrower attribute.
3. Run `just chk` for Nix configuration changes only after the source-safety gate succeeds. Do not substitute a deployment command for local validation.
4. If validation cannot complete because of the environment or the source-safety gate, report the exact command, failure, and unverified configurations. Do not claim success from partial evaluation.
5. Summarize changed files, routing decisions, affected hosts and architectures, completed checks, and any remaining manual or runtime verification. Mention explicitly that no deployment occurred.
