---
name: nixcf-nixvim
description: Maintain and review this repository's Nixvim and Home Manager Neovim configuration. Use for changes to fool/nvim modules, plugins, Markdown rendering, LSP servers or executable packages, Treesitter grammars, keymaps, providers, raw Lua or Vimscript, the Workman runtime keymap, host-scoped Neovim options, or optional AI behavior across the GTR7, XPS13, and Pi profiles.
---

# Maintain Nixcf Nixvim

## Establish current context

1. Read [the repository overview](../../README.md) and [flake.nix](../../flake.nix). Derive the current host, user, architecture, Home Manager profile, and Nixvim module entry from source.
2. Read the affected profile's `readme.md` and `default.nix`, plus [the Nvim overview](../../fool/nvim/readme.md) and [maintenance guidance](../../fool/nvim/nvim-config-skills.md).
3. Open only the affected files under `fool/nvim/`, their import site, and directly related profile files. Inspect [flake.lock](../../flake.lock) only when version or input compatibility matters.
4. Treat source and `flake.lock` as authoritative for current options, enabled hosts, package names, and versions. Use documentation as navigation and update it when behavior or structure changes.
5. Inspect the relevant working-tree diff before editing. Preserve unrelated user changes. For a behavior-preserving refactor, capture the affected wrapper derivation paths or relevant evaluated values before editing so they can be compared afterward.

## Resolve decisions before editing

Stop and ask one concise question when the request and source do not determine any of these choices:

- whether a plugin is install-only or must run setup, and which setup behavior or provider is intended;
- which host/profile scope applies, especially whether the Pi's LSP-disabled behavior must remain unchanged;
- whether a colliding or changed keymap must replace, coexist with, or preserve the existing mapping;
- whether a refactor is mechanical or intentionally changes observable behavior;
- whether a styling request changes only highlight colors or also visible decorations and layout, such as heading rules, code-block borders, padding, or labels, especially under a translucent terminal;
- which runtime secret source or credential-loading mechanism to use.

Never ask for secret plaintext. Offer only repository-compatible runtime choices, such as an environment variable or a protected runtime file, when the source does not already establish one. Continue without asking when the user or current source answers the decision unambiguously.

## Keep ownership explicit

- Let Nixvim own the Neovim wrapper, plugins, generated init, editor options, keymaps, autocmds, runtime files, and plugin configuration.
- Let Home Manager own surrounding CLI tools and any LSP executable whose Nixvim server sets `package = null`.
- Give each LSP server exactly one package owner. Keep its server enablement and executable package under the same `fool.nvim.lsp` condition, and verify that the installed package provides the command the server launches.
- Prefer a typed Nixvim module over `extraPlugins` plus raw setup. Use `extraPlugins` for plugins without adequate module support, and add only the smallest required raw Lua/Vimscript fragment.
- Keep provider enablement, provider executable discovery, and plugin provider selection separate. Do not imply that installing an AI plugin configures or authenticates a provider.
- Pass module dependencies explicitly through arguments or evaluated configuration. Do not rely on import order, an unrelated module's implementation detail, or an undeclared package appearing in `PATH`.
- Use runtime values such as `vim.env.HOME` or declarative package paths instead of hardcoded user home directories. Report pre-existing hardcoded paths encountered outside the requested change; do not silently expand a mechanical task to fix them.
- Check package and plugin availability for every affected architecture. Treat the Pi as `aarch64-linux`; do not assume an `x86_64-linux` output exists there.

## Make the change

1. Place option declarations, wrapper settings, and surrounding `home.packages` ownership in `fool/nvim/default.nix`.
2. Place always-on editor behavior in `base.nix`, LSP-gated behavior in `lsp.nix`, AI-gated behavior in `ai.nix`, and Workman runtime mappings in `workman-p.vim`. Create a focused module only when that boundary materially improves cohesion, then import it explicitly.
3. Preserve option values, plugin load mode, module conditions, raw-code phase, `lib.mkOrder` ordering, and keymap semantics during a mechanical split. Separate behavioral changes into an explicit decision and diff.
4. Treat plugin `settings` as generated Lua, not raw data: Nixvim's `toLuaObject` drops empty lists and attrsets (`[ ]`/`{ }`), so a setting intended to clear a default list can silently disappear. Express the intent with a non-empty value or a highlight override, and inspect the generated init before building the wrapper.
5. When removing a style to eliminate a background, separate it from layout keys such as `width`, padding, and `position`. Removing those keys can move labels or content even though they do not control color.
6. Keep each added plugin's installation and setup together enough that the enable condition is obvious. Do not call setup for an install-only plugin unless the user chose that behavior.
7. For each LSP addition or change, trace `server -> command -> owning package -> enable condition -> affected architectures`. Do not silently repair an unrelated pre-existing mismatch; report it and ask whether to expand scope.
8. Keep Treesitter grammar selection intentional and architecture-compatible. Do not replace a deliberately small grammar set with the full grammar bundle without approval.
9. Preserve the Workman runtime filename and Nixvim runtime-file wiring unless the request explicitly changes them. Check keymap activation and deactivation mappings together.
10. Load API keys, tokens, and local AI/provider settings only at runtime. Never place their values in a Nix expression, generated init, Git-tracked file, command log, or Nix store path. Do not read or copy a secret while implementing editor configuration.
11. Update `fool/nvim/readme.md` and, when its maintenance rules change, `fool/nvim/nvim-config-skills.md`. Keep host/profile descriptions consistent with their source switches.

## Validate proportionally

Run non-interactive checks from the repository root. Replace `HOST` and `USER` below with values derived from the current `flake.nix`.

1. Always run `git diff --check` and inspect the scoped diff.
2. Before any repo-consuming Nix command, run `.agents/skills/nixcf-secrets-agenix/scripts/check-nix-source-safety.sh`. Stop and report its path/category-only output if blocked; do not open reported sources or bypass it with a narrower wrapper attribute.
3. Prefer `just chk` once the final diff is stable; do not rerun it for every intermediate style tweak. Report a gate, cache, network, builder, or architecture limitation instead of claiming success from evaluation alone.
4. For a mechanical refactor, compare the captured derivation paths or evaluated configuration with the post-change result. Investigate any difference; do not treat a successful build alone as proof of behavioral equivalence.
5. Inspect the generated init before paying for a wrapper build. `build.initSource` is the uncompiled Lua source; `build.initFile` may be byte-compiled.

   ```sh
   init=$(nix build --no-link --print-out-paths ".#nixosConfigurations.HOST.config.home-manager.users.USER.programs.nixvim.build.initSource")
   grep -n -A20 'require("PLUGIN").setup' "$init"
   ```

   Confirm the changed keys survived serialization, especially lists and attrsets that may be empty. A setting absent from this file does not exist at runtime.

6. Build each affected wrapper without launching it:

   ```sh
   nix build --no-link ".#nixosConfigurations.HOST.config.home-manager.users.USER.programs.nixvim.build.package"
   ```

   Build both desktop wrappers for shared LSP changes. For a change shared by several hosts, compare `build.package.drvPath` first and build an identical derivation once. Also evaluate and, when an `aarch64-linux` builder is available, build the Pi wrapper for shared base/plugin/provider changes.

7. Run a headless smoke test against a successfully built wrapper. Isolate user state and keep fixture creation plus execution in one shell invocation:

   ```sh
   tmp=$(mktemp -d)
   mkdir -p "$tmp"/{home,config,data,state,cache}
   out=$(nix build --no-link --print-out-paths ".#nixosConfigurations.HOST.config.home-manager.users.USER.programs.nixvim.build.package")
   HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" \
     XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache" \
     "$out/bin/nvim" --headless '+qa!'
   rm -rf -- "$tmp"
   ```

   Add a focused, offline assertion for the changed wrapper behavior. For Workman changes, include `'+set keymap=workman-p'`; for a plugin change, assert module or command availability without contacting a provider. Do not use the standalone wrapper's `PATH` to prove that a Home Manager-owned LSP executable is installed, and do not let smoke tests write state into the repository.

8. For Markdown rendering or style changes, run the render audit against a desktop wrapper, reusing `$out` from the previous step:

   ```sh
   .agents/skills/nixcf-nixvim/scripts/check-render-bg.sh "$out/bin/nvim"
   ```

   It renders a fixture with headings, inline code, a fenced block, a quote, and a table, then fails if any highlight applied by the rendered marks carries a background. It exits 3 when render-markdown is disabled, so use a desktop wrapper; the Pi is intentionally excluded.

9. Evaluate the relevant Home Manager switch when conditional behavior matters. Verify a Home Manager-owned LSP executable through the evaluated `home.packages` or an affected Home Manager activation build, separately from the wrapper smoke test. Confirm that the Pi remains LSP-disabled unless the user explicitly changes its profile, and do not make a Pi smoke test depend on LSP or AI components.
10. Treat `just nvim` and `just nvim <host>` as interactive development commands: they build and then launch Neovim. Run them only when the user explicitly requests an interactive UI test and the source-safety gate succeeds immediately beforehand.

## Keep scope safe

- Do not update flake inputs, deploy a host, create deployment tags, commit changes, access secrets, or fetch from the network unless separately and explicitly authorized.
- Do not broaden a review or mechanical refactor into unrelated cleanup.
- Report affected hosts, ownership decisions, intentional behavior changes (including decorations removed or layout shifts made for styling), completed checks, and every unverified item in the handoff.
