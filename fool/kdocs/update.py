#!/usr/bin/env python3
"""Update the pinned kdocs-cli binary and kdocs skill."""

from __future__ import annotations

import base64
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


CDN_BASE = "https://wpsai.wpscdn.cn/skillhub/pro"
CLI_ASSET_TEMPLATE = "kdocs-cli-{version}-linux-amd64.tar.gz"
VERSION_PATTERN = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")
# 回退用的 `kdocs-cli upgrade --check` 人类可读输出：已最新时实测为
# "Already on the latest version: <version>"，同时兼容 "Latest version: <version>"。
UPGRADE_CHECK_PATTERN = re.compile(
    r"^(?:Latest version|Already on the latest version):\s*v?(\d+\.\d+\.\d+)\s*$",
    re.MULTILINE,
)
SOURCE_FILE = Path(__file__).resolve().with_name("source.json")


class UpdateError(RuntimeError):
    """A safe, user-facing update failure."""


def version_tuple(version: str) -> tuple[int, int, int]:
    match = VERSION_PATTERN.fullmatch(version)
    if match is None:
        raise UpdateError(f"invalid version: {version!r}")
    return tuple(int(part) for part in match.groups())


def fetch_text(url: str) -> str:
    last_error: Exception | None = None
    for attempt in range(3):
        try:
            request = Request(url, headers={"User-Agent": "nixcf-kdocs-updater"})
            with urlopen(request, timeout=30) as response:
                return response.read().decode("utf-8")
        except (HTTPError, URLError, TimeoutError, UnicodeDecodeError) as error:
            last_error = error
            if attempt < 2:
                time.sleep(2**attempt)
    raise UpdateError(f"cannot fetch {url}: {last_error}")


def run_cli(arguments: list[str]) -> str:
    try:
        result = subprocess.run(
            ["kdocs-cli", *arguments],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError as error:
        raise UpdateError("kdocs-cli executable not found") from error
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip() or error.stdout.strip() or f"exit code {error.returncode}"
        raise UpdateError(f"kdocs-cli {' '.join(arguments)} failed: {detail}") from error
    return result.stdout


def query_latest_version(current_version: str) -> str:
    """Ask the official CLI for the latest skill/CLI version.

    Primary source is the JSON API behind `check_skill_update`; the
    human-readable `upgrade --check` output is a fallback.
    """
    try:
        payload = json.loads(run_cli([
            "call",
            "check_skill_update",
            f"version={current_version}",
            "skill_name=kdocs",
        ]))
    except json.JSONDecodeError:
        payload = None

    if isinstance(payload, dict):
        data = payload.get("data")
        latest = data.get("latest") if isinstance(data, dict) else None
        if isinstance(latest, str) and VERSION_PATTERN.fullmatch(latest):
            return latest

    match = UPGRADE_CHECK_PATTERN.search(run_cli(["upgrade", "--check"]))
    if match is None:
        raise UpdateError("cannot determine latest version from kdocs-cli output")
    return match.group(1)


def fetch_checksums(version: str) -> dict[str, str]:
    url = f"{CDN_BASE}/v{version}/releases/checksums.txt"
    checksums: dict[str, str] = {}
    for line in fetch_text(url).splitlines():
        parts = line.split()
        if len(parts) == 2 and re.fullmatch(r"[0-9a-fA-F]{64}", parts[0]):
            checksums[parts[1]] = parts[0].lower()
    if not checksums:
        raise UpdateError(f"no usable checksums parsed from {url}")
    return checksums


def digest_to_sri(digest: Any) -> str:
    if not isinstance(digest, str) or not digest.startswith("sha256:"):
        raise UpdateError(f"missing or invalid digest: {digest!r}")
    hex_digest = digest.removeprefix("sha256:")
    if re.fullmatch(r"[0-9a-fA-F]{64}", hex_digest) is None:
        raise UpdateError(f"invalid SHA-256 digest: {digest!r}")
    encoded = base64.b64encode(bytes.fromhex(hex_digest)).decode("ascii")
    return f"sha256-{encoded}"


def read_source() -> tuple[str, tuple[int, int, int], str, str]:
    try:
        source = json.loads(SOURCE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise UpdateError(f"cannot read {SOURCE_FILE}: {error}") from error

    version = source.get("version")
    cli_hash = source.get("cliHash")
    skill_hash = source.get("skillHash")
    if not all(isinstance(value, str) for value in (version, cli_hash, skill_hash)):
        raise UpdateError(f"invalid source metadata in {SOURCE_FILE}")
    return version, version_tuple(version), cli_hash, skill_hash


def prefetch(url: str, expected_hash: str | None) -> str:
    arguments = ["nix", "store", "prefetch-file", "--json"]
    if expected_hash is not None:
        arguments += ["--expected-hash", expected_hash]
    arguments.append(url)
    try:
        result = subprocess.run(arguments, check=True, capture_output=True, text=True)
    except FileNotFoundError as error:
        raise UpdateError("nix executable not found") from error
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip() or error.stdout.strip() or f"exit code {error.returncode}"
        raise UpdateError(f"cannot prefetch {url}: {detail}") from error

    try:
        prefetched = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise UpdateError(f"invalid nix prefetch response: {error}") from error
    actual_hash = prefetched.get("hash")
    if not isinstance(actual_hash, str):
        raise UpdateError(f"nix prefetch returned no hash for {url}")
    if expected_hash is not None and actual_hash != expected_hash:
        raise UpdateError(
            f"prefetched hash {actual_hash!r} does not match expected {expected_hash!r}"
        )
    return actual_hash


def write_source(version: str, cli_hash: str, skill_hash: str) -> None:
    payload = {"version": version, "cliHash": cli_hash, "skillHash": skill_hash}
    temporary_path: Path | None = None
    try:
        descriptor, temporary_name = tempfile.mkstemp(
            dir=SOURCE_FILE.parent,
            prefix=f".{SOURCE_FILE.name}.",
            text=True,
        )
        temporary_path = Path(temporary_name)
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        temporary_path.chmod(0o644)
        os.replace(temporary_path, SOURCE_FILE)
        temporary_path = None
    except OSError as error:
        raise UpdateError(f"cannot update {SOURCE_FILE}: {error}") from error
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


def main() -> int:
    try:
        current_version, current_tuple, current_cli_hash, current_skill_hash = read_source()
        latest_version = query_latest_version(current_version)
        latest_tuple = version_tuple(latest_version)

        cli_asset = CLI_ASSET_TEMPLATE.format(version=latest_version)
        cli_url = f"{CDN_BASE}/v{latest_version}/releases/{cli_asset}"
        skill_url = f"{CDN_BASE}/v{latest_version}/kdocs.zip"

        if latest_tuple < current_tuple:
            raise UpdateError(
                f"refusing to downgrade from {current_version} to {latest_version}"
            )
        if latest_tuple == current_tuple:
            prefetch(cli_url, current_cli_hash)
            prefetch(skill_url, current_skill_hash)
            print(f"Kdocs {current_version} is up to date")
            return 0

        checksums = fetch_checksums(latest_version)
        expected_cli_hex = checksums.get(cli_asset)
        if expected_cli_hex is None:
            raise UpdateError(f"{cli_asset} missing from checksums.txt for {latest_version}")

        cli_hash = prefetch(cli_url, digest_to_sri(f"sha256:{expected_cli_hex}"))
        skill_hash = prefetch(skill_url, None)
        write_source(latest_version, cli_hash, skill_hash)
        print(f"Updated Kdocs {current_version} -> {latest_version}")
        return 0
    except UpdateError as error:
        print(f"Kdocs update failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
