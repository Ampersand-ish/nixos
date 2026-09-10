# Communication and file transfer apps (chrome, cloud sync, remmina, kdeconnect live in their own aspects).
{ ... }:
{
  flake.modules.homeManager.pkgs-comms =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
        fragments
      ];
    };
}
