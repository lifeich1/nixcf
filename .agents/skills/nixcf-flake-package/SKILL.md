---
name: nixcf-flake-package
description: Safely add, change, pin, update, or remove flake inputs and external packages in the nixcf NixOS repository. Use for flake.nix or flake.lock changes; nixpkgs channel changes; input follows relationships; packages consumed from an input; fool/overlays package exposure; or wiring an external package or module into a host, Home Manager profile, NixOS module, or Home Manager module.
---

# nixcf Flake Packages

Change inputs and external packages without broad lock churn, architecture regressions, or confused ownership between the flake, overlays, modules, and consumers.

## Establish the current graph

1. Read the repository `AGENTS.md`, root `README.md`, and `flake.nix` completely. Treat `flake.nix` and `flake.lock` as truth; do not copy versions or enabled state from prose.
2. Read the `readme.md` in each affected directory and its parent, then open only the relevant host, profile, module, and overlay sources.
3. Inspect the existing working-tree diff before editing. Preserve unrelated and pre-existing changes.
4. Trace the requested item through all applicable layers:

| Layer | Responsibility |
|---|---|
| `flake.nix` input | Declare source, ref, `flake = false`, and nested `follows` relationships. |
| `flake.lock` | Record resolved revisions and the transitive input graph; mutate only with Nix. |
| Flake composition | Pass inputs through module arguments or import an input-provided NixOS/Home Manager module. |
| `fool/overlays` | Expose a shared external package as one owned `pkgs.<name>` attribute. |
| `os/` or `fool/` module | Implement reusable system or user behavior and declare options. |
| `host/` or `home/` consumer | Select the hosts/profiles that enable or consume the feature. |

Use targeted `rg` searches for the input name, package attribute, module import, and option. Do not assume an input is unused merely because it is absent from an overlay.

## Pass the decision and authorization gate

A direct request to add, change, pin, update, or remove a named input authorizes only the requested `flake.nix` input change. Mutating `flake.lock` requires explicit authorization as well: accept an initial request that explicitly includes updating or reconciling the lock, otherwise ask before running the lock command. Research, diagnosis, package recommendations, or an ambiguous request do not authorize either change.

Before editing an input or mutating `flake.lock`, establish and state:

- the exact input name, source, owner, ref/revision, and whether it is a flake;
- the stability choice, especially `nixpkgs` versus `nixpkgs-stable`;
- the exact package/module output and intended integration layer;
- the target hosts/profiles and therefore both required systems;
- the named lock target and expected transitive churn.

Ask an interactive, concise question when any of those decisions is materially ambiguous. Also ask before accepting unexpected lock churn. Use the interactive input mechanism when available; otherwise ask directly. Do not silently choose a source fork, branch, stability channel, output named `default`, target host, or broader update scope.

Do not treat permission for one input as permission for all-input updates. Never deploy, commit, tag, access secrets, or update unrelated inputs unless explicitly requested.

## Choose one package integration path

- Import an input-provided module in flake composition when the upstream output is itself a NixOS or Home Manager module. Preserve its existing `inputs.<name>.follows` relationships unless the requested compatibility change requires otherwise.
- Consume `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}.<output>` directly when one reusable module owns the package and no `pkgs.<name>` API is needed.
- Add an overlay under `fool/overlays/<name>/` when system and user modules share the package, multiple consumers need a stable `pkgs.<name>` name, or package ownership otherwise belongs in the package set. Import it once from `fool/overlays/default.nix` and document the owning option and consumers.
- Treat `flake = false` inputs as source trees, not flakes with `packages` or module outputs. Add an explicit packaging layer only if the request requires one.
- Use the existing `pkgs-stable` module argument only when the chosen stability policy calls for it. Do not create a second ad-hoc nixpkgs import inside a consumer.

Keep reusable logic in `os/` or `fool/`; keep host/profile files to selection. Add imports and update affected `readme.md` files according to repository conventions.

## Protect follows and overlay semantics

Inspect the corresponding lock nodes before changing `follows`. Retain shared nixpkgs following where it prevents duplicate graphs, and retain deliberately disabled or independent inputs when required by upstream compatibility. Do not add `follows` merely to reduce the lockfile.

For overlays:

- derive the output system from the target package set, never `builtins.currentSystem`;
- confirm the exact `packages.<system>.<output>` exists for every target system;
- use one owner for each `pkgs.<name>` attribute and avoid shadowing a nixpkgs attribute accidentally;
- avoid `final.<same-name>` self-reference and recursive nixpkgs imports;
- use `final` only for dependencies that should see the composed overlays, and `prev` for the pre-overlay package set;
- verify unfree policy in the applicable package-set import rather than assuming it globally applies.

## Reconcile the lockfile narrowly

1. Run `.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh` before any repo-consuming Nix command. Stop on a nonzero result; do not open reported sources or bypass the gate with a narrower update/evaluation.
2. Read the installed Nix version and the local help for `nix flake update` and `nix flake lock` immediately before choosing a command. Their experimental CLI has changed; do not reuse deprecated forms from memory. Commands that only display installed-version or CLI help may run before the source-safety gate because they do not consume the repository.
3. Prefer the current supported named-input update form for an existing input. For a newly declared or removed input, use the currently documented lock reconciliation that preserves already-current entries.
4. Do not use the repository's all-input update recipe for a targeted change.
5. Never hand-edit `flake.lock`.
6. Compare the before/after input graph and `git diff -- flake.nix flake.lock`. Allow changes to the named node and explainable transitive nodes only. Stop and ask before keeping unrelated top-level changes or surprising source/ref changes.

If the necessary command will fetch from the network or mutate the lock and the user's request did not explicitly authorize that exact operation, ask first. Do not discard the user's existing lockfile edits to narrow a diff.

## Validate by architecture and consumer

Resolve host names, profiles, users, and systems from the current `flake.nix`. For a shared package, explicitly check both `x86_64-linux` and the Pi's `aarch64-linux`; for a host-specific package, check every selected host system.

1. Re-run the source-safety gate immediately before validation. If blocked, skip every repo-consuming Nix command and report the unvalidated outputs/hosts.
2. Probe the exact input package or module output for each target system. A successful x86 output does not establish Pi availability.
3. Evaluate every affected `nixosConfigurations.<host>.config.system.build.toplevel.drvPath` with lock writes disabled. This catches module arguments, overlay exposure, option wiring, package availability, unfree policy, and host/profile consumption.
4. Run `just chk` for Nix configuration changes, then `git diff --check`.
5. Inspect the final diff for preserved `follows`, intended imports and enablement, updated directory documentation, and unrelated lock churn.

Do not deploy as validation. If evaluation or checks cannot run because an input is unavailable, a target architecture lacks an output, the network is unavailable, or approval is absent, report the exact unvalidated host/output and reason instead of weakening the check.

## Report the result

Summarize the declared source/ref, package or module output, exposure path, enabled consumers, affected systems, lock nodes changed, and validation performed. Call out any intentional transitive churn, unverified architecture, or follow-up decision.
