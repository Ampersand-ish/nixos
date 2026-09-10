# The 2 TB Crucial P3 Plus data disk (ext4 label "Files"). Never touched by disko.
{ ... }:
{
  flake.modules.nixos.files-disk = {
    fileSystems."/mnt/Files" = {
      device = "/dev/disk/by-uuid/a425327f-f5e7-45e0-91c0-a26f0fb0aedd";
      fsType = "ext4";
      options = [
        "defaults"
        "nofail"
        "x-gvfs-show"
      ];
    };
  };
}
