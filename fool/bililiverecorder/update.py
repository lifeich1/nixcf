#!/usr/bin/env python3
"""Update the pinned stable BililiveRecorder container tag."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import sys
import tempfile
import time
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen


REGISTRY = "https://ghcr.io"
REPOSITORY = "bililiverecorder/bililiverecorder"
TOKEN_URL = f"{REGISTRY}/token?{urlencode({'service': 'ghcr.io', 'scope': f'repository:{REPOSITORY}:pull'})}"
TAGS_URL = f"{REGISTRY}/v2/{REPOSITORY}/tags/list?n=100"
VERSION_PATTERN = re.compile(
    r"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$"
)
NEXT_LINK_PATTERN = re.compile(r'<([^>]+)>\s*;\s*rel="?next"?')
SOURCE_FILE = Path(__file__).resolve().with_name("source.json")


class UpdateError(RuntimeError):
    """A safe, user-facing update failure."""


def version_tuple(version: str) -> tuple[int, int, int]:
    match = VERSION_PATTERN.fullmatch(version)
    if match is None:
        raise UpdateError(f"invalid stable semver tag: {version!r}")
    return tuple(int(part) for part in match.groups())


def request_json(url: str, headers: dict[str, str]) -> tuple[Any, str | None]:
    last_error: Exception | None = None
    for attempt in range(3):
        try:
            request = Request(url, headers=headers)
            with urlopen(request, timeout=30) as response:
                return json.load(response), response.headers.get("Link")
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as error:
            last_error = error
            if attempt < 2:
                time.sleep(2**attempt)
    raise UpdateError(f"cannot query {url}: {last_error}")


def registry_token() -> str:
    response, _ = request_json(
        TOKEN_URL,
        {
            "Accept": "application/json",
            "User-Agent": "nixcf-bililiverecorder-updater",
        },
    )
    if not isinstance(response, dict):
        raise UpdateError("GHCR token response is not an object")
    token = response.get("token") or response.get("access_token")
    if not isinstance(token, str) or not token:
        raise UpdateError("GHCR token response does not contain a token")
    return token


def fetch_tags() -> list[str]:
    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {registry_token()}",
        "User-Agent": "nixcf-bililiverecorder-updater",
    }
    tags: list[str] = []
    url: str | None = TAGS_URL
    visited: set[str] = set()

    while url is not None:
        if url in visited:
            raise UpdateError(f"GHCR returned a pagination loop at {url}")
        visited.add(url)

        response, link = request_json(url, headers)
        if not isinstance(response, dict):
            raise UpdateError("GHCR tags response is not an object")
        if response.get("name") != REPOSITORY:
            raise UpdateError(f"unexpected GHCR repository name: {response.get('name')!r}")
        page_tags = response.get("tags")
        if not isinstance(page_tags, list) or not all(
            isinstance(tag, str) for tag in page_tags
        ):
            raise UpdateError("GHCR tags response has an invalid tag list")
        tags.extend(page_tags)

        if link is None:
            url = None
            continue
        match = NEXT_LINK_PATTERN.search(link)
        if match is None:
            raise UpdateError(f"cannot parse GHCR pagination link: {link!r}")
        url = urljoin(url, match.group(1))

    return tags


def latest_stable_tag(tags: list[str]) -> tuple[str, tuple[int, int, int]]:
    candidates = [
        (version_tuple(tag), tag)
        for tag in tags
        if VERSION_PATTERN.fullmatch(tag) is not None
    ]
    if not candidates:
        raise UpdateError("no stable X.Y.Z tag found in GHCR")
    latest_tuple, latest_tag = max(candidates, key=lambda item: item[0])
    return latest_tag, latest_tuple


def read_source() -> tuple[str, tuple[int, int, int]]:
    try:
        source = json.loads(SOURCE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise UpdateError(f"cannot read {SOURCE_FILE}: {error}") from error

    version = source.get("version")
    if not isinstance(version, str):
        raise UpdateError(f"invalid source metadata in {SOURCE_FILE}")
    return version, version_tuple(version)


def write_source(version: str) -> None:
    temporary_path: Path | None = None
    try:
        descriptor, temporary_name = tempfile.mkstemp(
            dir=SOURCE_FILE.parent,
            prefix=f".{SOURCE_FILE.name}.",
            text=True,
        )
        temporary_path = Path(temporary_name)
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump({"version": version}, handle, ensure_ascii=False, indent=2)
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
        current_version, current_tuple = read_source()
        latest_version, latest_tuple = latest_stable_tag(fetch_tags())

        if latest_tuple < current_tuple:
            raise UpdateError(
                f"refusing to downgrade from {current_version} to {latest_version}"
            )
        if latest_tuple == current_tuple:
            print(f"BililiveRecorder {current_version} is up to date")
            return 0

        write_source(latest_version)
        print(f"Updated BililiveRecorder {current_version} -> {latest_version}")
        return 0
    except UpdateError as error:
        print(f"BililiveRecorder update failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
