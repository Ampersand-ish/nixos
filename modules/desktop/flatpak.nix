# Flatpak for the three apps not in nixpkgs (Riff, SciDAVis, Picard). Add flathub once by hand:
#   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
{ ... }:
{
  flake.modules.nixos.flatpak = {
    services.flatpak.enable = true;
  };
}
