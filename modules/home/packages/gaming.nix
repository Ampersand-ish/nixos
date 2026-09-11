# Gaming launchers and Wine tooling (steam/protontricks/gamemode are system-side; mangohud has its own aspect).
{ ... }:
{
  flake.modules.homeManager.pkgs-gaming =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        lutris
        heroic
        umu-launcher
        winetricks
        gamescope
        goverlay
        furmark
        wineWow64Packages.stagingFull # closest in-tree equivalent of wine-cachyos (staging + full deps)
      ];
    };
}
