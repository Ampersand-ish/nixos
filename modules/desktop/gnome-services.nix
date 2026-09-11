# Desktop plumbing the GNOME apps expect (gvfs, udisks2, dconf, thumbnails).
{ ... }:
{
  flake.modules.nixos.gnome-services =
    { pkgs, ... }:
    {
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      programs.dconf.enable = true;
      services.gnome.sushi.enable = true;
      services.accounts-daemon.enable = true;
      environment.systemPackages = with pkgs; [
        nautilus
        # loupe comes from home-manager (modules/home/packages/media.nix), wrapped
        # to force GSK_RENDERER=cairo — keep only one copy so the wrapper is used.
        papers
        file-roller
        gnome-text-editor
        gnome-calculator
        gnome-disk-utility
        baobab
        snapshot
        showtime
        decibels
        simple-scan
        ffmpegthumbnailer
        adwaita-icon-theme
      ];
    };
}
