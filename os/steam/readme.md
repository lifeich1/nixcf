# Steam

`default.nix` 通过 `fool.steam.enable` 开启上游 `programs.steam`，并用
`programs.steam.extraCompatPackages` 声明式注入 `pkgs.proton-ge-bin`。上游 module 会把
GE-Proton 的 `steamcompattool` output 放进 `STEAM_EXTRA_COMPAT_TOOLS_PATHS`，重启 Steam
后即可在游戏属性的兼容性列表中选择 GE-Proton。

- 仅 GTR7 启用；XPS13 与 Pi 不启用。
- GE-Proton 版本跟随 pinned nixpkgs（当前为 GE-Proton11-11），随 `just update` 更新，
  不新增 flake input 或单独 pin。
- `programs.steam.enable` 会自动启用 `hardware.steam-hardware`、32 位图形
  （`hardware.graphics.enable32Bit`）和 PipeWire ALSA 32 位兼容；本 module 不重复声明。
- 不开放 Steam 入站端口：`remotePlay`、`dedicatedServer`、
  `localNetworkGameTransfers` 的 `openFirewall` 均保持默认 `false`。需要 Remote Play
  时再显式开启上游 option，并同步更新 `os/firewall/readme.md`。
- 不启用 gamemode、gamescope session 或 protonup-qt；本 module 只声明 Steam 与
  GE-Proton。
