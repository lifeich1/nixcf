#!/usr/bin/env bash
# Deploy clean-tree guard.
#
# Exits 0 and prints the current commit revision when the worktree is clean
# (no staged, unstaged or untracked changes). Exits 1 when dirty.
#
# ALLOW_DIRTY=1 prints "<rev>-dirty" (caller must not create a normal deploy
# tag for such a revision) but still exits 0 so an auditable emergency deploy
# can proceed.
set -euo pipefail

if [[ "${ALLOW_DIRTY:-0}" == "1" ]]; then
  rev="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
  echo "warning: ALLOW_DIRTY=1, deploying dirty tree at ${rev}" >&2
  echo "${rev}-dirty"
  exit 0
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: worktree is dirty; commit or stash changes, or set ALLOW_DIRTY=1 (no normal deploy tag)" >&2
  exit 1
fi

git rev-parse HEAD
