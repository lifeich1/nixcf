# Reasonix CLI

`default.nix` 声明 `fool.reasonix.enable`，启用后将预编译的 Reasonix CLI 安装到用户环境。当前包只支持 `x86_64-linux`，GTR7 与 XPS13 通过 `home/desktop-common.nix` 启用，Pi4B 不启用。

`package.nix` 从 GitHub Releases 下载固定版本的 `reasonix-linux-amd64.tar.gz`，只安装其中的静态 `reasonix` 可执行文件。版本和 SHA-256 保存在 `source.json`，不使用会漂移的 latest URL。

运行 `just update-reasonix` 可查询最新稳定 `vX.Y.Z` CLI release，核对 GitHub asset digest 与 Nix 预取 hash 后原子更新 `source.json`。脚本忽略 draft、preview、Desktop 和 Studio release；任何查询、资产或校验失败都会保留原文件并返回失败。
