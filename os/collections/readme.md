# 系统软件集合

`default.nix` 无条件提供少量基础系统工具，并导入 `gtr.nix`。

`gtr.nix` 通过 `fool.collections.gtr` 启用 NetworkManager、Plasma、PipeWire/JACK 和实时音频限制。GTR7 与 XPS13 都启用该集合，Pi 不启用。
