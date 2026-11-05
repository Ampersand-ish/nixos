# CAD, EDA, slicing and reference management (Riff/SciDAVis/Picard via flatpak).
{ ... }:
{
  flake.modules.homeManager.pkgs-cad =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        freecad
        openscad
        kicad
        orca-slicer
        lycheeslicer
        drawio
        inkscape
        zotero
        zmk-studio
      ];
    };
}
