#!/usr/bin/env python3
"""Update the pinned Reasonix stable CLI release."""

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


REPOSITORY = "esengine/DeepSeek-Reasonix"
ASSET_NAME = "reasonix-linux-amd64.tar.gz"
RELEASES_URL = f"https://api.github.com/repos/{REPOSITORY}/releases?per_page=100"
TAG_PATTERN = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")
VERSION_PATTERN = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")
SOURCE_FILE = Path(__file__).resolve().with_name("source.json")


class UpdateError(RuntimeError):
    """A safe, user-facing update failure."""


def version_tuple(version: str, pattern: re.Pattern[str]) -> tuple[int, int, int]:
    match = pattern.fullmatch(version)
    if match is None:
        raise UpdateError(f"invalid version: {version!r}")
    return tuple(int(part) for part in match.groups())


def github_headers() -> dict[str, str]:
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "nixcf-reasonix-updater",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers


def fetch_releases() -> list[dict[str, Any]]:
    last_error: Exception | None = None
    for attempt in range(3):
        try:
            request = Request(RELEASES_URL, headers=github_headers())
            with urlopen(request, timeout=30) as response:
                releases = json.load(response)
            if not isinstance(releases, list):
                raise UpdateError("GitHub releases response is not a list")
            return releases
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as error:
            last_error = error
            if attempt < 2:
                time.sleep(2**attempt)
    raise UpdateError(f"cannot query GitHub releases: {last_error}")


def latest_stable_release(
    releases: list[dict[str, Any]],
) -> tuple[str, tuple[int, int, int], dict[str, Any]]:
    candidates: list[tuple[tuple[int, int, int], str, dict[str, Any]]] = []
    for release in releases:
        if release.get("draft") or release.get("prerelease"):
            continue
        tag = release.get("tag_name")
        if not isinstance(tag, str) or TAG_PATTERN.fullmatch(tag) is None:
            continue
        candidates.append((version_tuple(tag, TAG_PATTERN), tag, release))

    if not candidates:
        raise UpdateError("no stable vX.Y.Z release found")

    selected_version, selected_tag, selected_release = max(candidates, key=lambda item: item[0])
    assets = selected_release.get("assets")
    if not isinstance(assets, list):
        raise UpdateError(f"release {selected_tag} has no asset list")
    matching_assets = [asset for asset in assets if asset.get("name") == ASSET_NAME]
    if len(matching_assets) != 1:
        raise UpdateError(
            f"release {selected_tag} has {len(matching_assets)} matching {ASSET_NAME} assets"
        )

    return selected_tag, selected_version, matching_assets[0]


def digest_to_sri(digest: Any) -> str:
    if not isinstance(digest, str) or not digest.startswith("sha256:"):
        raise UpdateError(f"missing or invalid GitHub asset digest: {digest!r}")
    hex_digest = digest.removeprefix("sha256:")
    if re.fullmatch(r"[0-9a-fA-F]{64}", hex_digest) is None:
        raise UpdateError(f"invalid SHA-256 digest: {digest!r}")
    encoded = base64.b64encode(bytes.fromhex(hex_digest)).decode("ascii")
    return f"sha256-{encoded}"


def read_source() -> tuple[str, tuple[int, int, int], str]:
    try:
        source = json.loads(SOURCE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise UpdateError(f"cannot read {SOURCE_FILE}: {error}") from error

    version = source.get("version")
    source_hash = source.get("hash")
    if not isinstance(version, str) or not isinstance(source_hash, str):
        raise UpdateError(f"invalid source metadata in {SOURCE_FILE}")
    return version, version_tuple(version, VERSION_PATTERN), source_hash


def prefetch(url: str, expected_hash: str) -> str:
    try:
        result = subprocess.run(
            [
                "nix",
                "store",
                "prefetch-file",
                "--json",
                "--expected-hash",
                expected_hash,
                url,
            ],
            check=True,
            capture_output=True,
            text=True,
        )
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
    if actual_hash != expected_hash:
        raise UpdateError(
            f"prefetched hash {actual_hash!r} does not match GitHub digest {expected_hash!r}"
        )
    return actual_hash


def write_source(version: str, source_hash: str) -> None:
    payload = {"version": version, "hash": source_hash}
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
        current_version, current_tuple, current_hash = read_source()
        tag, latest_tuple, asset = latest_stable_release(fetch_releases())
        latest_version = tag.removeprefix("v")
        expected_hash = digest_to_sri(asset.get("digest"))

        canonical_url = (
            f"https://github.com/{REPOSITORY}/releases/download/{tag}/{ASSET_NAME}"
        )
        asset_url = asset.get("browser_download_url")
        if asset_url != canonical_url:
            raise UpdateError(
                f"unexpected asset URL for {tag}: {asset_url!r}; expected {canonical_url!r}"
            )

        if latest_tuple < current_tuple:
            raise UpdateError(
                f"refusing to downgrade from {current_version} to {latest_version}"
            )
        if latest_tuple == current_tuple:
            if current_hash != expected_hash:
                raise UpdateError(
                    f"release {tag} digest differs from the pinned hash; refusing tag mutation"
                )
            print(f"Reasonix {current_version} is up to date")
            return 0

        actual_hash = prefetch(canonical_url, expected_hash)
        write_source(latest_version, actual_hash)
        print(f"Updated Reasonix {current_version} -> {latest_version}")
        return 0
    except UpdateError as error:
        print(f"Reasonix update failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
