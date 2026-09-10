# Office suite and GNOME desktop utilities.
{ ... }:
{
  flake.modules.homeManager.pkgs-office =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        libreoffice # `libreoffice-fresh` is now a deprecation alias of libreoffice-stable
        gnome-calculator
        gnome-text-editor
        file-roller
        baobab
        simple-scan
        gnome-disk-utility
        nautilus
      ];
    };
}
