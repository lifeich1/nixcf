---
name: nixcf-deploy
description: Safely plan, validate, build, activate, deploy, verify, tag, or roll back hosts in the nixcf NixOS flake. Use for requests involving `just chk`, NixOS builds or tests, local `nixos-rebuild` activation, remote `just pi`/`just xps`/`just gtr7` or multi-host deployment, deployment tags, post-deploy health checks, failed switches, generation recovery, or rollback of `nixos-gtr7`, `nixos-xps13`, or `nixos-pi4b`.
---

# Nixcf Deploy

Treat deployment as a staged operation whose local evaluation, live activation, verification, and provenance can fail independently. Preserve a recovery path and require explicit authority before every live or repository-mutating stage.

## Establish the requested operation

Classify the request before running commands:

| Class | Effect | Authorization |
|---|---|---|
| Plan/audit | Inspect source, Git metadata, and command semantics | Read-only request is enough |
| Validate/build | Run `just chk`, evaluate, or build a closure without activation | A validation/build request is enough |
| Test activation | Activate until reboot without making it the boot default | Require explicit live-activation authorization |
| Local switch | Activate locally and update the system profile | Require explicit local-switch authorization |
| Remote switch | Connect to and switch a target host | Require explicit target-specific deployment authorization |
| Multi-host switch | Switch an ordered set of remote hosts | Require explicit host scope and order; authorize each intended target |
| Rollback | Activate an earlier generation locally or remotely | Require explicit rollback target and authorization |
| Tag | Create a Git deployment tag | Require explicit tag authorization, including when bundled in a `just` recipe |

Do not treat “check,” “build,” “test,” “prepare,” or “plan” as permission to switch. Do not treat permission to switch as permission to tag unless the user explicitly selected a recipe after being told that it tags. Never infer permission to commit, clean, stash, reset, update inputs, edit secrets, or discard user work.

Ask one concise interactive question or batch when any material choice is missing:

- exact host or ordered multi-host scope;
- plan/build/test/switch/rollback intent;
- dirty-tree policy when the source is not clean and traceable;
- whether to stop after a failed check or explicitly bypass it;
- tagged `just` recipe versus an explicitly reviewed no-tag command;
- intended tag behavior after a partial deployment or tag failure;
- recovery route and acceptable maintenance impact for a live change.

Default to stopping when no safe assumption is available. Prefer a single-host rollout before a multi-host rollout.

## Read live sources

Read the repository `README.md` and `flake.nix`, then the target host and Home profile `readme.md` files. Read `justfile` before proposing or executing any recipe. Before opening `host/common.nix`, another potential credential source, or a content diff that may include one, run `.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh`; keep reported paths opaque while blocked. For operational work, read [references/deployment-reference.md](references/deployment-reference.md), but use its table only as a navigation aid: source code wins if it has changed where the gate permits inspection.

Extract and report before any activation:

- flake output name, `system`, `username`, `device`, and `homeModule` from the `hosts` registry in `flake.nix`;
- target address and exact recipe expansion from `justfile`;
- whether the command switches, uses `sudo`, connects remotely, deploys sequentially, or creates a tag;
- relevant services and expected application checks from the target configuration and diff.

Reject a requested target or recipe when the registry, host documentation, and recipe cannot be reconciled. Do not guess an address from documentation or memory.

## Preflight provenance and safety

Run read-only checks first and summarize, without printing secret contents:

```bash
git status --short --branch
git rev-parse --verify HEAD
git branch --show-current
git status --short -- flake.lock secrets
git diff --name-only -- flake.lock secrets
git diff --cached --name-only -- flake.lock secrets
```

Also determine the current commit, branch or detached-HEAD state, tracked modifications, and untracked paths. Inspect only secret filenames and Git status; never open, decrypt, copy, or log `.age` payloads, tokens, keys, or passwords.

Refuse a tagged deployment by default when any deployed source is dirty, untracked, detached without a deliberate policy, changes during preflight, or cannot be tied to the commit that the tag would reference. Explain that a Git tag points to a commit, while a path-based flake can build tracked working-tree changes that the tag does not capture. Ask the user to choose among cleaning/committing their own work, a deliberate no-tag deployment, or an exceptional explicitly authorized tagged override. Never perform the cleanup or commit implicitly.

Surface pending `flake.lock` and `secrets/` path changes separately. Do not update inputs or inspect secret contents. If either affects the deployment, require the user to acknowledge it before a live switch.

Run `.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh` before every repo-consuming Nix evaluation, build, check, activation, or deployment command. A nonzero result is a hard stop: do not open reported sources, bypass the gate with a narrower attribute, activate a previously unchecked dirty source, or deploy it. Report only the gate's path/category output.

Before live activation:

1. Run the source-safety gate, then `just chk` unless both already passed against the same source state.
2. Stop on failure. Show the failed check and ask explicitly before any bypass; never silently substitute a narrower successful evaluation.
3. Re-check `HEAD` and working-tree status after long builds or checks. Treat a changed source state as a new preflight.
4. Confirm the exact command, target, maintenance impact, automatic tag behavior, and recovery route.
5. Record the current generation/profile target on every host before switching. For remote targets, require a reachable independent or out-of-band recovery route when networking, SSH, boot, storage, firewall, or cache settings may change.

Do not claim that `just chk`, evaluation, or closure construction proves bootability, connectivity, service health, or successful activation.

## Choose the command deliberately

Prefer repository recipes only after reading their current definitions.

- Use `just chk` for the repository-wide flake check.
- Use a host-specific `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` or a reviewed `nixos-rebuild build --flake .#<host>` for a non-activating build. State any local result-link effect.
- Treat `nixos-rebuild test` as live activation even though it does not make the generation the boot default.
- Use `just nixos` for the intended local switch workflow only after confirming the local host matches the selected flake output. It snapshots the previous profile to `.prev-system`; it does not run `just chk` and does not create a deployment tag.
- Treat `just continue` only as a retry using an existing `.prev-system`, not as a fresh deployment or validation.
- Treat `just nixos-debug` as a checked local switch with verbose logs, but note that its current recipe does not create `.prev-system` or show `system-diff`.
- Use `just pi`, `just xps`, or `just gtr7` only when the user authorizes both the remote switch and the recipe's automatic deployment tag.
- Offer the exact underlying `nixos-rebuild switch` command from the current recipe, with its tag line omitted, when the user deliberately chooses a no-tag remote deployment. Reproduce source values; do not reconstruct them from memory.

The current `just all` workflow is a GTR7-only launcher that runs `just chk`, then Pi and XPS sequentially. It does not include GTR7, and each successful child switch attempts its own tag before the next host. Re-read it before use. For any multi-host workflow, preflight all hosts first, process strictly in the authorized order, and stop immediately on the first switch, verification, or tag failure. Never continue to later hosts after partial failure.

## Execute one stage at a time

Immediately before a live command, restate:

- operation and exact host;
- exact target address and remote user, if any;
- source commit and dirty-tree policy;
- command to run and whether it will create a tag;
- recorded previous generation and recovery method.

Run only the authorized command. Preserve complete error output while redacting accidental credentials. Do not retry a failed switch with different flags, run `just continue`, change proxies, alter caches, or invoke rollback without new authority.

If switching succeeds but tag creation fails, classify the result as **deployed but untagged**. Stop; do not redeploy merely to obtain a tag, invent a tag, or continue to the next host. If a tag is created but verification fails, classify it as **tagged deployment with failed verification** and move to the rollback decision. Never move, delete, overwrite, or repair a deployment tag without explicit authorization.

## Verify live state

Verify proportionally to the change and distinguish evidence layers:

1. **Source validation:** record the `just chk` or build result and source identity.
2. **Activation:** confirm the active system profile/generation differs as expected and resolves to the intended closure.
3. **Connectivity:** establish a fresh connection rather than relying on the deployment process's existing channel.
4. **System health:** inspect `systemctl is-system-running` and failed units, comparing known pre-existing degradation where available.
5. **Changed units:** verify every service/socket/timer materially affected by the diff.
6. **Application health:** perform a non-secret-bearing local or remote health check appropriate to the changed application.
7. **Tag provenance:** if authorized and created, confirm the new tag resolves to the preflight commit and report its name.

Do not expose secret-bearing environment variables or request bodies during health checks. Report skipped checks and their reason. Call the deployment live-successful only when activation, reconnection, and required health checks pass; otherwise report the exact partial state.

## Roll back safely

Define the rollback before switching: identify the recorded prior generation or profile path, the command that would reactivate it, and the console/SSH/physical route that remains available. Treat booting an older generation, runtime activation of a prior closure, and changing the default system profile as distinct recovery actions.

On failure:

1. Stop all later hosts and mutations.
2. Preserve the failed host, active-generation, tag, and connectivity facts.
3. State whether the host is reachable, switched, tagged, and healthy.
4. Propose the exact rollback command using the recorded generation and current access route.
5. Require explicit rollback authorization.
6. After rollback, verify generation, connectivity, failed units, and affected application health again.

Do not assume `nixos-rebuild --rollback` selects the intended generation when multiple switches occurred; use the recorded generation when an exact recovery is required. Do not remove a deployment tag automatically after rollback: a tag is repository history and requires a separate user decision.

## Report the outcome

Return a compact per-host result containing source commit/state, validation/build result, previous and active generation, connectivity, unit/application checks, tag name or no-tag status, and rollback status. Label each host as one of: planned only, validated only, built only, activated and healthy, deployed but untagged, activation failed, verification failed, rolled back and healthy, or rollback incomplete.
