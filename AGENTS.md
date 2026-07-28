# nixcf — NixOS Flake Handover Document

> **Author:** Lintd (lifeich1)
> **Repository:** `git@github.com:lifeich1/nixcf.git`
> **License:** WTFPL

## 1. Project Overview

This is a **NixOS flake-based configuration** managing 3 machines:

| Hostname | Hardware | Arch | User | Role |
|---|---|---|---|---|
| `nixos-gtr7` | AMD Ryzen 7 7840HS desktop | x86_64-linux | `fool` | Main PC (media, dev, gaming) |
| `nixos-xps13` | Dell XPS 13 9360 laptop | x86_64-linux | `fool` | Lightweight mobile setup |
| `nixos-pi4b` | Raspberry Pi 4B | aarch64-linux | `pi` | Homelab server |

**Key characteristics:**
- All inputs use **Chinese mirrors** (Tsinghua, USTC, SJTU, Gitee) for fast access
- Self-hosted **Attic binary cache** on the Pi4B at `http://my-pi:8080`
- **Agenix**-encrypted secrets (passwords, xray config)
- **Gitmoji-style** commit messages
- Homelab ecosystem: Gitea, Attic, KMS server, hobob bot, Syncthing

---

## 2. Architecture

```
flake.nix  ─────────────────────────────────────────────────────────┐
  │   defines 3 NixOS configurations via nixosSystem                │
  │                                                                 │
  └── nixos-xps13 ──────────────────────────────────────────────────┐
  │   modules = [                                                   │
  │     nixos-hardware.dell-xps-13-9360                              │
  │     (pass_config x64_config { username="fool"; device="xps13";  │
  │                                home-nix = ./home/lightpad; })    │
  │   ]                                                             │
  │                                                                 │
  ├── nixos-gtr7 ───────────────────────────────────────────────────┤
  │   modules = [                                                   │
  │     (pass_config x64_config { username="fool"; device="gtr7";})  │
  │     nixos-hardware.common-pc, common-cpu-amd, ...                │
  │   ]                                                             │
  │                                                                 │
  └── nixos-pi4b ───────────────────────────────────────────────────┐
      modules = [                                                   │
        nixos-hardware.raspberry-pi-4                                │
        ./os/atticd                                                 │
        (pass_config pi4b_config { home-nix = ./home/micro-srv; })   │
      ]                                                             │
                                                                    │
Each target's module list is built by add_basic_mods which adds:     │
    ./os  ./secrets  ./host/common.nix                              │
    ./host/<name>/configuration.nix                                  │
    ./fool/overlays                                                  │
    nur.modules.nixos.default                                        │
    inputs.agenix.nixosModules.default                               │
    home-manager.nixosModules.home-manager                           │
```

**Data flow:**

```
flake.nix
  ├── os/default.nix           ← base system (hostname, locale, SSH)
  │     ├── os/collections/    ← system packages
  │     ├── os/firewall/       ← firewall rules
  │     ├── os/plasma/         ← KDE Plasma 6 desktop
  │     ├── os/syncthing/      ← file sync across devices
  │     ├── os/gitea/          ← self-hosted git service
  │     ├── os/atticd/         ← binary cache daemon (pi4b only)
  │     ├── os/vlmcsd/         ← KMS server container
  │     ├── os/hobob/          ← bot system service
  │     ├── os/virtualbox/     ← VirtualBox host/guest
  │     ├── os/sudo/           ← sudo config
  │     ├── os/proxychains/    ← proxychains config
  │     └── secrets/           ← agenix secrets
  │
  ├── host/common.nix          ← shared Nix settings, substituters, xray
  ├── host/<name>/             ← per-host config (boot, kernel, etc.)
  │
  └── home-manager (fool/ + home/<host>/)
        ├── fool/default.nix   ← root module (proxy, gpg options)
        ├── fool/<module>/     ← 15+ user-level modules
        └── home/<host>/       ← per-host feature toggles
```

---

## 3. Directory Structure

```
nixcf/
├── flake.nix                   # Flake entry: inputs, outputs, helpers
├── flake.lock                  # Locked inputs
├── README.md
├── LICENSE                     # WTFPL
├── .gitignore
├── AGENTS.md                   # ← This file
│
├── fool/                       # Home-manager user modules
│   ├── default.nix             #   Root: imports, proxy/gpg options
│   ├── alacritty/              #   Alacritty terminal
│   ├── attic/                  #   Attic watch-store service
│   ├── bililiverecorder/       #   Bilibili live recorder (podman)
│   ├── cargo/                  #   Cargo mirror (Tsinghua)
│   ├── cfg-ssh/                #   SSH client config
│   ├── com-lemonade/           #   Lemonade reverse tunnel proxy
│   ├── cp-guard/               #   Competitive programming guard
│   ├── fastfetch/              #   Fastfetch system info
│   ├── git/                    #   Git config (LFS, difftastic, proxy)
│   ├── hobob/                  #   Hobob bot package
│   ├── kitty/                  #   Kitty terminal
│   ├── misc/                   #   Utility packages (per-host variants)
│   │   ├── default.nix
│   │   ├── gtr.nix             #     GTR7-specific apps
│   │   └── nixbuild.nix        #     Nix dev tools
│   ├── nvim/                   #   Neovim (LSP, AI, nightly)
│   ├── overlays/               #   Package overlays
│   │   └── hobob/
│   ├── wezterm/                #   Wezterm terminal
│   ├── xray/                   #   Xray installer script
│   └── zsh/                    #   ZSH (p10k, oh-my-zsh, skim)
│       ├── default.nix
│       ├── instant-prompt.nix
│       ├── skim.nix
│       ├── zshrc / zshenv / p10k.zsh
│
├── os/                         # NixOS system modules
│   ├── default.nix             #   Base system (hostname, locale, SSH)
│   ├── atticd/                 #   Attic daemon (binary cache server)
│   ├── collections/            #   System packages
│   │   ├── default.nix
│   │   └── gtr.nix             #     Plasma, PipeWire, fcitx5, etc.
│   ├── firewall/               #   Firewall rules
│   ├── gitea/                  #   Gitea service
│   ├── hobob/                  #   Hobob system service
│   ├── plasma/                 #   KDE Plasma 6 (SDDM, Wayland)
│   ├── proxychains/            #   Proxychains config
│   ├── sudo/                   #   Sudo (NOPASSWD option)
│   ├── syncthing/              #   Syncthing (multi-device)
│   ├── virtualbox/             #   VirtualBox host/guest
│   └── vlmcsd/                 #   KMS server (podman)
│
├── home/                       # Per-host home-manager entry points
│   ├── pc/default.nix          #   GTR7: full feature set
│   ├── lightpad/default.nix    #   XPS13: lighter config
│   └── micro-srv/              #   Pi4B: minimal headless
│       ├── default.nix
│       └── fastfetch-config.jsonc
│
├── host/                       # Per-host NixOS configs
│   ├── common.nix              #   Shared: GC, substituters, xray
│   ├── nixos-xps13/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── nixos-gtr7/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── nixos-pi4b/
│       ├── configuration.nix
│       ├── atticd.env
│       └── ds3231.dts           # RTC device tree overlay
│
├── secrets/                    # Agenix-encrypted secrets
│   ├── default.nix             #   Secret definitions
│   ├── secrets.nix             #   Key-to-secret mapping
│   ├── xray-config.json.age
│   ├── pi-pass.age
│   ├── gtr-pass.age
│   └── xps-pass.age
│
├── tools/
│   └── use-proxy.portable.sh   # Nix-daemon proxy helper
│
└── skill/
    └── commit-message.md       # Gitmoji commit conventions
```

---

## 4. Module Convention (fool.* namespace)

Every user module follows this pattern:

```nix
{ config, pkgs, lib, ... }: with lib;
let cfg = config.fool.<module-name>;
in {
  options.fool.<module-name> = {
    enable = mkEnableOption "<description>";
    # ... additional options
  };
  config = mkIf cfg.enable {
    # ... config that activates when enabled
  };
};
```

**All modules are gated** by boolean `fool.<name>.enable` options, toggled per-host in `home/<host>/default.nix`.

### Proxy System

The `fool.proxy` subsystem provides automatic proxy configuration:

- `fool.proxy.port` — socks5 port (default: 10809)
- `fool.proxy.use-pi` — route proxy through Pi4B (`my-pi:10809`)
- `fool.proxy.tcp_url` — computed: `host:port`
- `fool.proxy.socks5_url` — computed: `socks5://host:port`
- `fool.proxy.has-pi` — system-level: add `my-pi` to `/etc/hosts`

---

## 5. Host Details

### nixos-gtr7 (AMD Ryzen 7 7840HS)
- **Boot:** systemd-boot
- **Network:** NetworkManager
- **Key features:** KDE Plasma 6, autologin, VirtualBox, PipeWire audio, binfmt aarch64 emulation
- **Home:** `home/pc/default.nix` — full feature set (bililiverecorder, cp-guard, nvim lsp+ai, etc.)
- **Hardware modules:** common-pc, common-cpu-amd, common-cpu-amd-pstate, common-cpu-amd-raphael-igpu, common-pc-ssd

### nixos-xps13 (Dell XPS 13 9360)
- **Boot:** systemd-boot
- **Network:** NetworkManager
- **Key features:** Lightweight, xray, syncthing, Intel-only hardware
- **Home:** `home/lightpad/default.nix` — lighter (no bililiverecorder, nvim lsp-only)

### nixos-pi4b (Raspberry Pi 4B)
- **Boot:** U-Boot + ext4
- **Kernel:** linux_rpi4
- **Key features:** DS3231 RTC, hobob, gitea, vlmcsd, atticd, firewall
- **User:** `pi` (SSH key auth only, no password)
- **Home:** `home/micro-srv/default.nix` — minimal (zellij, zsh, git)
- **State version:** 24.05 (NixOS), 23.11 (home-manager)

---

## 6. Secrets Management (Agenix)

All secrets are encrypted with SSH keys and managed via `agenix`:

| Secret | Path | Used By |
|---|---|---|
| `xray-config.json.age` | `/usr/local/etc/xray/config.json` | All hosts |
| `pi-pass.age` | Pi user password | nixos-pi4b |
| `gtr-pass.age` | Fool user password | nixos-gtr7 |
| `xps-pass.age` | Fool user password | nixos-xps13 |

**Key mapping** (defined in `secrets/secrets.nix`):
- Pi4B SSH key can decrypt **all** secrets
- GTR7 and XPS13 keys can only decrypt their own

To add/update secrets:
```bash
# Edit a secret
agenix -e secrets/<name>.age

# Add new secret to secrets.nix with authorized keys
```

---

## 7. Build & Deploy (justfile)

| Command | Action |
|---|---|
| `just` | `nixos-rebuild switch` on current machine |
| `just chk` | `nix flake check` |
| `just update` / `just u` | `nix flake update` |
| `just nixos` | rebuild local + show diff via `nvd` |
| `just continue` / `just cont` | retry rebuild after failure |
| `just g` / `just nixos-debug` | rebuild with verbose trace |
| `just pi` | deploy to Pi4B (`my-pi`) |
| `just xps` | deploy to XPS13 (`192.168.3.21`) |
| `just gtr7` | deploy to GTR7 (`10.42.0.2`) |
| `just all` | chk + deploy pi + xps |
| `just nvim` | hardlink nvim configs for fast dev |
| `just zsh` | hardlink zsh configs for fast dev |
| `just du` | run nix-du, show store graph |

**Deploy flow:**
Each deploy command auto-tags the commit with `pi-rN`, `xps-rN`, or `gtr7-rN`.

**Proxy setting for nix-daemon:**
```bash
just proxy              # inject socks5 proxy
just no-proxy           # remove proxy
just disable-commu      # remove nix-community cache
just cfg-rollback       # restore nix.conf backup
```

---

## 8. Flake Inputs

| Input | Source | Notes |
|---|---|---|
| `nixpkgs` | Tsinghua mirror, nixos-unstable | Main package source |
| `nixpkgs-stable` | Tsinghua mirror, nixos-25.11 | For stable packages |
| `home-manager` | GitHub (nix-community) | Follows nixpkgs |
| `nur` | GitHub (nix-community) | Nix User Repository |
| `nixos-hardware` | GitHub | Hardware modules |
| `agenix` | GitHub (ryantm) | Secrets management |
| `minpac` | Gitee mirror | Flake=false |
| `nixvim` | GitHub (nix-community) | Neovim distribution |
| `hobob` | Gitee (lifeich0) | Personal bot |
| `cp-guard` | Gitee (lifeich0) | CP guard service |

---

## 9. Common Workflows

### Adding a new module

```bash
# 1. Create module dir
mkdir -p fool/<name>

# 2. Create default.nix with fool.<name>.enable option
# 3. Import it in fool/default.nix
# 4. Enable in home/<host>/default.nix
```

### Adding a new host

```bash
# 1. Add to flake.nix outputs
# 2. Create host/<name>/configuration.nix (+ hardware scan)
# 3. Create home/<name>/default.nix
# 4. Create secrets entries if needed
# 5. Add justfile target for deployment
```

### Decrypting secrets

```bash
# Secrets are auto-decrypted at build time via agenix.
# To manually view:
agenix -d secrets/<name>.age
```

### Updating flake.lock

```bash
just update
# or
nix flake update --debug
```

---

## 10. Git & Commit Conventions

This project uses **gitmoji-style commit messages**, documented in `skill/commit-message.md`. The analysis of ~500 historical commits identified these conventions:

| Emoji | Meaning |
|---|---|
| `:sparkles:` | New feature/file |
| `:wrench:` | Config change |
| `:bug:` | Bug fix |
| `:recycle:` | Refactoring |
| `:memo:` | Documentation |
| `:arrow_up:` | Package/input update |
| `:technologist:` | Development tooling |
| `:alembic:` | Experimental |
| `:heavy_plus_sign:` | New dependency |
| `:see_no_evil:` | Add to .gitignore |
| `:lipstick:` | UI/formatting polish |

Message format: `<emoji> <component>: <short description>`

---

## 11. Key Design Decisions & Gotchas

1. **mirrors.tuna.tsinghua.edu.cn for nixpkgs** — uses git clone URL format, not tarball
2. **nix-community.cachix.org as last resort** — sometimes corrupted, can break home-manager
3. **`my-pi` hostname resolution** — Pi4B doesn't set `has_pi=true` (it IS the pi); others set `has_pi=true`
4. **stateVersion mismatch** — Pi4B NixOS is 24.05 but home-manager is 23.11
5. **Xray config** — loaded from agenix secret on all hosts, path: `/usr/local/etc/xray/config.json`
6. **Attic token** — hardcoded in `host/common.nix` (JWT expiring ~2029), considered safe since homelab-only
7. **Firewall non-strict** — allows wide port range (2048-65535), intended for homelab flexibility
8. **`pass_config` helper** — critical for passing per-host args (`username`, `device`, `home-nix`) to modules
9. **Private just recipes** — `tag-deploy` is private, auto-increments tag on each deploy
10. **GTR7 direct connection** — uses USB tethering IP `10.42.0.2` for faster rebuilds

---

## 12. Troubleshooting

| Symptom | Likely Fix |
|---|---|
| Build fails on nix-community cache | `just disable-commu` then retry |
| nix-daemon slow behind firewall | `just proxy` to route through socks5 |
| Build succeeds but deploy fails | `just cont` to retry |
| Password doesn't match | Re-encrypt `.age` file with correct SSH key |
| Missing `my-pi` host | Ensure `fool.proxy.has-pi` is enabled in `os/default.nix` |
| ALSA config lost after upgrade | `just fix-alsa-store` |

---

## 13. Future Considerations

- **NixOS 25.11 upgrade** — track `nixpkgs-stable` for migration
- **nixvim migration** — input already added, some modules need porting
- **New host workflow** — templates/ directory doesn't exist yet, would be useful
- **Homelab expansion** — atticd, gitea, hobob all ready for additional services
- **nixpkgs-review** — available in `fool.misc.nixbuild` for PR testing

---

*Generated by AI handover agent. Last updated: 2026-07-29*

