# kdocs-cli：官方 CDN 上的固定版本预编译二进制。
#
# URL 与 hash 由 `source.json` 固定（`just update-kdocs` 更新），不使用会漂移的
# latest URL；归档内为单文件 `kdocs-cli`（见 `releases/checksums.txt`）。
{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
stdenvNoCC.mkDerivation {
  pname = "kdocs-cli";
  inherit (source) version;

  src = fetchurl {
    url = "https://wpsai.wpscdn.cn/skillhub/pro/v${source.version}/releases/kdocs-cli-${source.version}-linux-amd64.tar.gz";
    hash = source.cliHash;
  };

  sourceRoot = ".";
  strictDeps = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 kdocs-cli "$out/bin/kdocs-cli"

    runHook postInstall
  '';

  meta = {
    description = "Kdocs (WPS cloud document) CLI";
    homepage = "https://www.kdocs.cn/latest";
    mainProgram = "kdocs-cli";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
