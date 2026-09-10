# KDE Connect daemon + tray indicator.
{ ... }:
{
  flake.modules.homeManager.kdeconnect =
    { ... }:
    {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };
}
