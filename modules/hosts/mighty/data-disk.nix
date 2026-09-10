# The 4 TB M.2 data disk (second slot on the B860-I). Already carries data — NEVER format it,
# and disko never touches it (only hostSpec.osDisk). It is not attached to any machine yet:
# once it is, `blkid` its partition, put the UUID here (and fix fsType if it isn't ext4).
{ ... }:
{
  flake.modules.nixos.mighty-data-disk = {
    fileSystems."/mnt/Files" = {
      device = "/dev/disk/by-uuid/CHANGEME-4TB-DATA-PARTITION-UUID";
      fsType = "ext4";
      options = [
        "defaults"
        "nofail"
        "x-gvfs-show"
      ];
    };
  };
}
