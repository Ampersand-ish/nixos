# PipeWire stack (alsa/pulse/jack) with WirePlumber, as on CachyOS.
{ ... }:
{
  flake.modules.nixos.audio =
    { pkgs, ... }:
    {
      security.rtkit.enable = true;
      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
      environment.systemPackages = with pkgs; [
        alsa-utils
        pavucontrol
      ];
    };
}
