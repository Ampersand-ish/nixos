# noctalia shell (bar/launcher/lock/idle/notifications/wallpaper). Spawned by
# niri (spawn-at-startup), so its systemd unit is off.
# Runtime GUI state lives in ~/.local/state/noctalia/settings.toml.
{ ... }:
{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = false;
        checkConfig = true;
        settings = ../../home/noctalia/config.toml;
      };
      home.packages = with pkgs; [
        ddcutil
        brightnessctl
        wl-clipboard
        wl-mirror
        matugen
        awww
        drm_info
        cliphist
      ];
      stylix.targets.noctalia.enable = false;
      stylix.targets.noctalia-shell.enable = false;
    };
}
