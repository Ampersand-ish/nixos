# MEGA mounted at /mnt/mega via rclone with a 50G VFS cache. Mounts the drive's
# top-level "MEGA" folder (where all the data lives), not the account root, so
# its contents appear directly in /mnt/mega. Auth comes from
# sops (secrets/rclone.conf, encrypted for admin+mighty+moonwhite); the mega
# remote (user/pass) lives there, never in git. x-systemd.automount: the mount
# happens on first access, so an offline boot costs nothing -- opening it while
# offline just errors until the network is up, and works on retry. Idle timeout
# unmounts after 60m of inactivity. Not imported by the vm host.
{ ... }:
{
  flake.modules.nixos.rclone-mega =
    { config, pkgs, ... }:
    {
      sops.secrets."rclone.conf" = {
        sopsFile = ../../secrets/rclone.conf;
        format = "binary"; # full rclone config, not a yaml/dotenv key-value file
        mode = "0400";
        # Nautilus (gvfs) mounts this fstab entry via setuid mount, which runs
        # the rclone helper as the invoking user; root-only 0400 would make
        # that path fail with "Failed to load config file: permission denied".
        owner = config.users.users.ampersand.name;
      };

      environment.systemPackages = [ pkgs.rclone ];

      fileSystems."/mnt/mega" = {
        device = "mega:MEGA";
        fsType = "rclone";
        options = [
          "nodev"
          "nofail"
          "_netdev"
          "x-systemd.automount"
          "x-systemd.idle-timeout=60m"
          "allow_other"
          "args2env"
          "config=${config.sops.secrets."rclone.conf".path}"
          "cache_dir=/var/cache/rclone"
          "vfs_cache_mode=full"
          "vfs_cache_max_size=50G"
          "uid=${toString config.users.users.ampersand.uid}"
          "gid=${toString config.users.groups.users.gid}"
          # gvfs: show as a mounted drive in Nautilus ("MEGA", remote-folder icon).
          "x-gvfs-show"
          "x-gvfs-name=MEGA"
          "x-gvfs-icon=folder-remote"
        ];
      };
    };
}