# OpenCode agent CLI with its config directory kept out-of-store.
{ ... }:
{
  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.opencode ];
      desktop.outOfStore.opencode = "home/opencode";
    };
}
