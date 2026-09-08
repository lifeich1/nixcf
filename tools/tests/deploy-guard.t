#!/usr/bin/env bash
# Tests for tools/deploy-guard.sh in a temporary git repository.
set -euo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/deploy-guard.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$TMP"
git init -q
git config user.email test@example.com
git config user.name Test
echo hi > f
git add f
git commit -qm init

ntests=0
passed=0

# 1. clean tree
ntests=$((ntests+1))
echo "test $ntests: clean tree"
rev="$(ALLOW_DIRTY=0 "$GUARD")"
if [[ -n "$rev" ]]; then
  echo "  PASS: rev=$rev"
  passed=$((passed+1))
else
  echo "  FAIL"
fi

# 2. untracked file
ntests=$((ntests+1))
echo "test $ntests: untracked → reject"
echo x > untracked
if "$GUARD" >/dev/null 2>&1; then
  echo "  FAIL (should have rejected)"
else
  echo "  PASS"
  passed=$((passed+1))
fi
rm untracked

# 3. staged change
ntests=$((ntests+1))
echo "test $ntests: staged → reject"
echo y >> f && git add f
if "$GUARD" >/dev/null 2>&1; then
  echo "  FAIL (should have rejected)"
else
  echo "  PASS"
  passed=$((passed+1))
fi
git reset -q HEAD f && git checkout -- . 2>/dev/null

# 4. unstaged change
ntests=$((ntests+1))
echo "test $ntests: unstaged → reject"
echo z >> f
if "$GUARD" >/dev/null 2>&1; then
  echo "  FAIL (should have rejected)"
else
  echo "  PASS"
  passed=$((passed+1))
fi
git checkout -- . 2>/dev/null

# 5. ALLOW_DIRTY=1 with untracked
ntests=$((ntests+1))
echo "test $ntests: ALLOW_DIRTY=1 with dirty tree"
echo w >> f
out="$(ALLOW_DIRTY=1 "$GUARD")"
if [[ "$out" == *-dirty ]]; then
  echo "  PASS: rev=$out"
  passed=$((passed+1))
else
  echo "  FAIL: unexpected output: $out"
fi

echo "---"
echo "${passed}/${ntests} tests passed"
[[ "$passed" == "$ntests" ]]