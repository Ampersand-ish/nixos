# udiskie: automount removable media with notifications and a tray icon.
{ ... }:
{
  flake.modules.homeManager.udiskie =
    { ... }:
    {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "auto";
      };
    };
}
