# Plymouth boot splash: pure black background with the NixOS snowflake logo.
# The built-in spinfinity theme has the right layout (centred logo, no text)
# but hard-codes a blue gradient in its theme file, overriding the black
# background plymouth is compiled with. So this module ships a copy of
# spinfinity with the background recoloured to black and the boot-up progress
# bar removed. Stylix's plymouth target is disabled: it paints the splash
# with the wallpaper-derived palette and renders progress text.
{ ... }:
{
  flake.modules.nixos.plymouth =
    { pkgs, ... }:
    {
      boot.plymouth.enable = true;
      stylix.targets.plymouth.enable = false;
      boot.plymouth.theme = "nixos-black";
      boot.plymouth.themePackages = [
        (pkgs.runCommand "plymouth-theme-nixos-black" { } ''
          dir=$out/share/plymouth/themes/nixos-black
          mkdir -p $dir
          cp -r ${pkgs.plymouth}/share/plymouth/themes/spinfinity/. $dir/
          mv $dir/spinfinity.plymouth $dir/nixos-black.plymouth
          substituteInPlace $dir/nixos-black.plymouth \
            --replace-fail 'BackgroundStartColor=0x0073b3' 'BackgroundStartColor=0x000000' \
            --replace-fail 'BackgroundEndColor=0x00457e' 'BackgroundEndColor=0x000000' \
            --replace-fail 'UseProgressBar=true' 'UseProgressBar=false' \
            --replace-fail 'ImageDir=${pkgs.plymouth}/share/plymouth/themes//spinfinity' "ImageDir=$dir"
          ln -s ${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png $dir/header-image.png
        '')
      ];
      # nixpkgs default is a 48x48 white snowflake; use the full-colour logo.
      boot.plymouth.logo = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";

      # No console text during boot: plymouth owns the screen from the initrd
      # on, and kernel/udev messages stay quiet behind it. loglevel 0 hides
      # even kernel errors — use the boot menu's plymouth.enable=0 escape to
      # debug boot failures.
      boot.consoleLogLevel = 0;
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "rd.udev.log_level=3"
      ];
    };
}