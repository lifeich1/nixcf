# Egress reference

Read this when the proxy endpoint must be discovered, when a proxied command fails in a confusing way, or when the nixcf derivation chain needs to be traced. Verify every value against current source; nothing here replaces runtime discovery.

## Endpoint discovery commands

```sh
# 1. Already-exported proxy settings (respect these instead of overriding)
env | grep -iE '^(all|https?)_proxy='

# 2. What proxychains4 itself will use
awk '/^\[ProxyList\]/{f=1;next} /^\[/{f=0} f && NF>=3 {print $1, $2, $3}' \
  /etc/proxychains.conf ~/.proxychains/proxychains.conf 2>/dev/null

# 3. Reachability of the endpoint (not of the target)
nc -z HOST PORT && echo "port open"
ss -lntp 2>/dev/null | grep PORT

# 4. Confirm egress end-to-end through the proxy
curl -sS --max-time 10 --socks5-hostname HOST:PORT -o /dev/null -w '%{http_code}\n' https://api.github.com
```

The `awk` program prints only the proxy type, host, and port — it never prints credentials or unrelated configuration. Prefer it over dumping the whole file.

## proxychains semantics

| Setting | Effect | Consequence for the agent |
|---|---|---|
| `strict_chain` | Every configured proxy must be used in order | One dead proxy breaks everything; verify reachability first |
| `dynamic_chain` | Skips dead proxies | More tolerant, but harder to reason about which proxy carried the traffic |
| `proxy_dns` | DNS resolution happens at the proxy | Equivalent to `socks5h://`; required when local DNS is poisoned |
| `remote_dns_subnet` | Subnet reserved for proxied DNS | Leave as configured; do not retune to "fix" failures |
| `tcp_read_time_out` / `tcp_connect_time_out` | Proxy-side timeouts | A slow target can look like a dead proxy; raise only for diagnosis |

proxychains intercepts libc calls through `LD_PRELOAD`. It cannot proxy UDP, so QUIC/HTTP-3-only clients must be forced to TCP. Statically linked binaries and Go binaries that bypass libc resolution may ignore the preload entirely — use the explicit `--socks5-hostname` or `socks5h://` route for those.

## sudo and environment traps

- `sudo` sanitizes the environment, dropping `LD_PRELOAD`; `sudo proxychains4 ...` is **not** proxied. Use `sudo -E proxychains4 ...` when the command genuinely needs root, or configure the service.
- `sudo -E` preserves more environment than you may want; prefer configuring the specific service (for example the `nix-daemon` drop-in) over exporting broad variables.
- Exported `https_proxy` affects every child process in that shell. Scope it with an inline prefix and unset it if you must export.

## Failure triage

| Symptom | Likely cause | Next check |
|---|---|---|
| `Could not resolve host` with no proxy | Local DNS blocked | Discover endpoint, retry through proxy |
| `Connection timed out` through proxy | Proxy host down, port closed, or firewall | `nc -z HOST PORT`; check the proxy host's service and firewall |
| `Connection reset` / TLS handshake failure | Target blocking, or a proxy that does not forward TLS | Retry once; then report target-side |
| HTTP 403/451 with a body | Target-side policy or geo-block | Proxy may not help; report the response |
| `error: unable to download ... Connection timed out` from nix | Daemon-side fetch ignoring shell env | Use the daemon recipe, not a shell prefix |
| Works with `curl` but not with a CLI tool | Tool ignores `LD_PRELOAD` or has its own proxy config | Use the tool's native proxy setting |

## nixcf derivation chain

Non-secret endpoints have a single source of truth; trace them in this order instead of copying values:

| Layer | File | Holds |
|---|---|---|
| Data | `os/homelab/endpoints.nix` | `proxy.socksPort`, `pi.lanAddress`, `pi.hostName` |
| System options | `os/homelab/default.nix` | Typed `fool.homelab.*` defaults plus the `use-pi` switch |
| System proxy | `os/proxychains/default.nix` | `programs.proxychains` entry named `lray`, host chosen by `use-pi` |
| Home derivation | `fool/default.nix` | `fool.proxy.tcp_url` and `fool.proxy.socks5_url` |
| Operations | `justfile` (`proxy`, `no-proxy`, `test`), `tools/proxy.sh` | nix-daemon drop-in management and prefetch check |

Read the port at runtime rather than hardcoding it:

```sh
nix eval .#homelabEndpoints.proxy.socksPort
```

`fool.homelab.proxy.use-pi = true` points proxychains at the Pi's LAN address; `false` points it at `127.0.0.1`. The flake asserts that `use-pi` requires the Pi to be resolvable, so a resolution failure is a configuration signal, not something to patch locally.

## no_proxy and exclusions

`justfile` and `tools/proxy.sh` each carry a `HOST_NO_PROXY` list that must stay identical. It exists to keep `localhost`, LAN hosts, and mirrors out of the proxy. When a fetch to a mirror fails through the proxy, the fix is to add that host to both lists in a deliberate configuration change — not to widen `no_proxy` to `*`, which would silently route everything.

## Restoring state

| Action | Enable | Revert |
|---|---|---|
| One-off command | inline `env`/`proxychains4` prefix | nothing to revert |
| Shell-wide variables | `export https_proxy=...` | `unset https_proxy ALL_PROXY` |
| nix-daemon | `just proxy [host]` / `tools/proxy.sh [host]` | `just no-proxy` / `tools/proxy.sh --no-proxy` |

Both daemon recipes require `sudo` and restart `nix-daemon`. Confirm the drop-in is gone (`ls /run/systemd/system/nix-daemon.service.d/`) before reporting the task complete.
