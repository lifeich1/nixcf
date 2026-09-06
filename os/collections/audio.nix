# audio collection：PipeWire（ALSA/Pulse 兼容）+ rtkit，不含 JACK 与实时限制。
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fool.collections;
in
{
  options.fool.collections = {
    audio = mkEnableOption "audio collection: PipeWire(alsa/pulse) + rtkit";
  };

  config = mkIf cfg.audio {
    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
