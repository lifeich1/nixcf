{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
stdenvNoCC.mkDerivation {
  pname = "reasonix";
  inherit (source) version;

  src = fetchurl {
    url = "https://github.com/esengine/DeepSeek-Reasonix/releases/download/v${source.version}/reasonix-linux-amd64.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";
  strictDeps = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 reasonix "$out/bin/reasonix"

    runHook postInstall
  '';

  meta = {
    description = "DeepSeek-native AI coding agent for the terminal";
    homepage = "https://github.com/esengine/DeepSeek-Reasonix";
    license = lib.licenses.mit;
    mainProgram = "reasonix";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
