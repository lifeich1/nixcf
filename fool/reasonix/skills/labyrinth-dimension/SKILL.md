---
name: labyrinth-dimension
description: Reach the public internet through a SOCKS5 proxy when the direct route is blocked or censored. Use when a clone, fetch, package install, API call, or nix operation fails with DNS errors, connect timeouts, resets, or HTTP 403/451, when the user asks to reach GitHub or another blocked external resource, or when proxy and nix-daemon egress must be enabled and then restored.
---

# Labyrinth Dimension

Cross into the proxied dimension only when the direct route is genuinely blocked, discover the endpoint instead of inventing one, and leave no proxy state behind.

## Decide whether egress is needed

Try the direct route first with a short timeout, then classify the failure:

```sh
curl -sS --max-time 8 -o /dev/null -w '%{http_code}\n' https://github.com
```

| Symptom | Reading |
|---|---|
| DNS resolution failure, connect timeout, connection reset, TLS handshake failure, HTTP 403/451 | Proxy candidate |
| HTTP 404/401/500 with a response body | Target-side problem; a proxy will not help |
| Success | Do not proxy |
| Target is a LAN host, `localhost`, or a configured mirror | Do not proxy; these belong in `no_proxy` |

Never proxy traffic that already works, and never widen exclusions to "proxy everything".

## Discover the endpoint, never guess it

Resolve the SOCKS5 endpoint in this order and stop at the first hit:

1. **Existing environment** — if `ALL_PROXY`/`all_proxy`, `https_proxy`, or `http_proxy` is already set, use that endpoint and do not override it.
2. **proxychains configuration** — the first `[ProxyList]` entry is what `proxychains4` itself uses:

   ```sh
   awk '/^\[ProxyList\]/{f=1;next} /^\[/{f=0} f && NF>=3 {print $1, $2, $3}' /etc/proxychains.conf ~/.proxychains/proxychains.conf 2>/dev/null
   ```

   Because `proxychains4` reads this file, a wrapped command needs no endpoint argument.
3. **Repository-provided value** — inside the nixcf flake only, cross-check the declared port instead of trusting memory:

   ```sh
   nix eval .#homelabEndpoints.proxy.socksPort
   ```

   The host comes from `os/homelab/endpoints.nix` (`pi.lanAddress`) and the proxy profile from `os/proxychains/default.nix`. Use this to confirm, not to replace steps 1–2.
4. **Nothing found** — stop and ask the user for `host:port`. Never fall back to a remembered address or a default port.

Confirm the endpoint before blaming the target:

```sh
curl -sS --max-time 10 --socks5-hostname HOST:PORT -o /dev/null -w '%{http_code}\n' https://api.github.com
```

## Run the command through the proxy

| Situation | Command |
|---|---|
| Arbitrary command, any protocol, DNS at the proxy | `proxychains4 <cmd> ...` |
| One-off `curl` | `curl --socks5-hostname HOST:PORT ...` |
| `git` clone/fetch | `git -c http.proxy=socks5h://HOST:PORT clone ...` |
| Tool that reads proxy environment variables | `ALL_PROXY=socks5h://HOST:PORT https_proxy=socks5h://HOST:PORT <cmd> ...` |
| `nix` client-side fetch | `proxychains4 nix flake prefetch github:owner/repo` |

Rules:

- Prefer `socks5h://` over `socks5://` so DNS resolves at the proxy; `proxychains4` does the same when `proxy_dns` is enabled.
- Scope the change to the single command with an `env`-style prefix. If you must `export`, `unset` it in the same shell afterwards.
- SOCKS5 carries no UDP; tools forcing QUIC/UDP must fall back to TCP.
- `sudo` strips `LD_PRELOAD`, so `sudo proxychains4 ...` is not proxied. Use `sudo -E proxychains4 ...`, or change the service configuration instead — see below.

## nix and nix-daemon egress

The daemon does not inherit your shell environment, so a per-command prefix is not enough.

- Read the repository recipe before running it; the nixcf `just proxy` recipe writes a `nix-daemon` drop-in and restarts the daemon.
  - `just proxy [host]` — enable (requires `sudo`, changes live system state).
  - `just no-proxy` — remove the drop-in and restart the daemon.
  - `tools/proxy.sh [host]` / `tools/proxy.sh --no-proxy` — the `just`-free equivalent.
- Client-side, user-level fetches can use `proxychains4 nix ...` or `https_proxy=socks5h://HOST:PORT nix ...`.
- Always restore the daemon state once the fetch is done. Leaving the drop-in makes all daemon traffic depend on the proxy.
- Keep `no_proxy` limited to `localhost`, LAN hosts, and mirrors. Never set it to `*` to "make things work".

## Handle failures without making them worse

- Proxy reachable but target failing → report the target-side error and stop; do not change the endpoint.
- Proxy unreachable → verify the proxy host is up and the port is listening (`ss -lntp | grep PORT` or `nc -z HOST PORT`), then report and stop.
- Intermittent success → record the exact command, endpoint, and result, and state what remains unverified.
- Do not "fix" a transient outage by editing `os/proxychains`, `fool.proxy`, `justfile`, or `tools/proxy.sh`. That is a separate configuration change requiring its own authorization.

## Guardrails

- Never print tokens, keys, passwords, or `.age` plaintext; registry credentials stay in their existing secret or environment source.
- Do not deploy, commit, tag, or update flake inputs as part of egress work.
- Do not run `just proxy` (sudo plus daemon restart) without explicit user authorization — it is a live system change.
- Do not leave exported proxy variables or a `nix-daemon` drop-in behind.
- Do not proxy excluded traffic: LAN, `localhost`, and mirror hosts.

## Report the outcome

State: why egress was needed, which discovery step produced the endpoint, the exact command(s) run, the direct-versus-proxy evidence (status code, exit code, error text), whether any system state changed and how it was restored, and anything still unverified. Detail on detection commands, proxychains semantics, and the nixcf derivation chain is in [references/egress-reference.md](references/egress-reference.md).
