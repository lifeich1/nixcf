# 系统软件集合

`default.nix` 无条件提供少量基础系统工具，并导入三个可组合 collection：

- `desktop.nix` → `fool.collections.desktop`：NetworkManager + Plasma（含 KDE Connect、
  fcitx5 等）。
- `audio.nix` → `fool.collections.audio`：PipeWire（ALSA/Pulse 兼容）+ rtkit，不含 JACK。
- `pro-audio.nix` → `fool.collections.pro-audio`：JACK（经 PipeWire）+ 实时调度限制
  （memlock 8192000 / rtprio 95）。

原 `fool.collections.gtr`（`gtr.nix`）已拆分删除（refactor-plan-04 阶段 9）。GTR7 与
XPS13 都启用 desktop + audio + pro-audio（两台都有 JACK/实时音频工作流），Pi 不启用。
