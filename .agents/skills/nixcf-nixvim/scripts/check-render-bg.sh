#!/usr/bin/env bash
# Render a Markdown fixture with render-markdown and fail if any highlight used
# by the rendered marks carries a background color.
#
# Usage: check-render-bg.sh /path/to/built/nvim
# Run against a desktop wrapper where fool.nvim.markdown is enabled.
set -euo pipefail

usage() {
  printf 'usage: %s PATH_TO_NVIM\n' "${0##*/}" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage

nvim_bin=$1
if [[ ! -x $nvim_bin ]]; then
  printf 'not executable: %s\n' "$nvim_bin" >&2
  exit 2
fi

workdir=$(mktemp -d "${TMPDIR:-/tmp}/nixcf-render-bg.XXXXXX")
cleanup() {
  rm -rf -- "$workdir"
}
trap cleanup EXIT

mkdir -p "$workdir/home" "$workdir/config" "$workdir/data" "$workdir/cache" "$workdir/state"

cat > "$workdir/sample.md" <<'MARKDOWN'
# Heading One

Some `inline code` and **bold** text with a [link](https://example.com).

```lua
print("hi")
```

## Heading Two

> a quote

| a | b |
|---|---|
| 1 | 2 |
MARKDOWN

cat > "$workdir/check.lua" <<'LUA'
local md = assert(vim.env.MD_FILE, 'MD_FILE is not set')
vim.cmd('edit ' .. vim.fn.fnameescape(md))
vim.cmd('set filetype=markdown')

local ok = pcall(vim.cmd, 'RenderMarkdown enable')
if not ok then
  print('RENDER_MARKDOWN_UNAVAILABLE')
  vim.cmd('qa!')
  return
end

-- Anti-conceal hides added text on the cursor line; park the cursor at the end
-- so the headings and code block above are rendered.
vim.cmd('normal! G')
vim.wait(500)

local marks = vim.api.nvim_buf_get_extmarks(0, -1, { 0, 0 }, { -1, -1 }, { details = true })
local bg = {}

local function check(group)
  if type(group) == 'table' then
    for _, item in ipairs(group) do
      check(item)
    end
    return
  end

  if type(group) ~= 'string' and type(group) ~= 'number' then
    return
  end
  if group == '' then
    return
  end

  local label, hl
  if type(group) == 'number' then
    label = 'id:' .. group
    hl = vim.api.nvim_get_hl(0, { id = group })
  else
    label = group
    hl = vim.api.nvim_get_hl(0, { name = group })
  end

  if hl.bg ~= nil then
    bg[label] = true
  end
end

for _, mark in ipairs(marks) do
  local details = mark[4]
  check(details.hl_group)
  for _, part in ipairs(details.virt_text or {}) do
    check(part[2])
  end
  for _, line in ipairs(details.virt_lines or {}) do
    for _, part in ipairs(line) do
      check(part[2])
    end
  end
end

local names = vim.tbl_keys(bg)
table.sort(names)
print('MARKS=' .. #marks)
print('BG_COUNT=' .. #names)
print('BG_GROUPS=' .. table.concat(names, ', '))
vim.cmd('qa!')
LUA

set +e
output=$(env -u NVIM -u VIMINIT \
  HOME="$workdir/home" \
  XDG_CONFIG_HOME="$workdir/config" \
  XDG_DATA_HOME="$workdir/data" \
  XDG_CACHE_HOME="$workdir/cache" \
  XDG_STATE_HOME="$workdir/state" \
  MD_FILE="$workdir/sample.md" \
  "$nvim_bin" --headless "+luafile $workdir/check.lua" '+qa!' 2>&1)
status=$?
set -e

# nvim may report a relocated log file when HOME is isolated; it is noise here.
filtered=$(printf '%s\n' "$output" | grep -v '^log: ' || true)

if ((status != 0)); then
  printf '%s\n' "$filtered" >&2
  printf 'nvim exited with status %d\n' "$status" >&2
  exit "$status"
fi

if grep -q '^RENDER_MARKDOWN_UNAVAILABLE' <<<"$filtered"; then
  printf '%s\n' "$filtered" >&2
  printf 'render-markdown is not enabled for this wrapper; use a desktop wrapper\n' >&2
  exit 3
fi

marks=$(sed -n 's/^MARKS=//p' <<<"$filtered" | tail -n 1)
count=$(sed -n 's/^BG_COUNT=//p' <<<"$filtered" | tail -n 1)
groups=$(sed -n 's/^BG_GROUPS=//p' <<<"$filtered" | tail -n 1)

if [[ -z $marks || -z $count ]]; then
  printf '%s\n' "$filtered" >&2
  printf 'render audit did not report results\n' >&2
  exit 1
fi

if ((marks == 0)); then
  printf 'render audit found no extmarks; rendering did not run\n' >&2
  exit 1
fi

if ((count > 0)); then
  printf 'render-markdown applied background highlights: %s\n' "$groups" >&2
  exit 1
fi

printf 'PASS: %d rendered marks, no background highlight groups\n' "$marks"
