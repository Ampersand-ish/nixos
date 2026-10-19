# Plymouth boot splash: pure black background with the NixOS snowflake logo.
# Uses the built-in spinfinity theme — nixpkgs compiles plymouth with a black
# background (0x000000) and wires boot.plymouth.logo in as spinfinity's
# header image. Stylix's plymouth target is disabled: it paints the splash
# with the wallpaper-derived palette and renders progress text.
{ ... }:
{
  flake.modules.nixos.plymouth =
    { pkgs, ... }:
    {
      boot.plymouth.enable = true;
      stylix.targets.plymouth.enable = false;
      boot.plymouth.theme = "spinfinity";
      # nixpkgs default is a 48x48 white snowflake; use the full-colour logo.
      boot.plymouth.logo = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";

      # No console text during boot: plymouth owns the screen from the initrd
      # on, and kernel/udev messages stay quiet behind it.
      boot.consoleLogLevel = 3;
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "rd.udev.log_level=3"
      ];
    };
}