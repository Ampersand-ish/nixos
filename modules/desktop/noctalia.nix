# noctalia shell (bar/launcher/lock/idle/notifications/wallpaper). Retained as an
# inactive fallback: to swap back, restore the host imports (noctalia instead of
# dms) AND the sharedModules entry `inputs.noctalia-shell.homeModules.default`
# in modules/system/home-manager.nix, then swap niri spawn/includes/keybinds.
# Spawned by niri (spawn-at-startup), so its systemd unit is off.
# Runtime GUI state lives in ~/.local/state/noctalia/settings.toml (delete it once after migrating).
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
