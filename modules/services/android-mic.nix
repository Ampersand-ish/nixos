# Virtual audio cable for the AndroidMic app: a PipeWire loopback pair.
# The AndroidMic PC app plays into the "AndroidMic" sink; recording apps
# pick up the matching "AndroidMic" source.
{
  flake.modules.nixos.android-mic =
    { pkgs, ... }:
    {
      services.pipewire.configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/20-android-mic.conf" ''
          context.modules = [
            {   name = libpipewire-module-loopback
                args = {
                    node.description = "AndroidMic"
                    capture.props = {
                        node.name = "AndroidMic_sink"
                        media.class = "Audio/Sink"
                        audio.position = [ FL FR ]
                    }
                    playback.props = {
                        node.name = "AndroidMic_source"
                        media.class = "Audio/Source"
                        audio.position = [ FL FR ]
                    }
                }
            }
          ]
        '')
      ];
    };
}
