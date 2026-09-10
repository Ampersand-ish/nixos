# Periodic scrub + trim.
{ ... }:
{
  flake.modules.nixos.btrfs-maintenance = {
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
    services.fstrim.enable = true;
  };
}
