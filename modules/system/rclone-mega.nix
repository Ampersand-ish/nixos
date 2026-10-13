# MEGA mounted at /mnt/mega via rclone with a 50G VFS cache. Auth comes from
# sops (secrets/rclone.conf, encrypted for admin+mighty+moonwhite); the mega
# remote (user/pass) lives there, never in git. nofail + _netdev so a boot
# never hangs on MEGA being unreachable. Not imported by the vm host.
{ ... }:
{
  flake.modules.nixos.rclone-mega =
    { config, pkgs, ... }:
    {
      sops.secrets."rclone.conf" = {
        sopsFile = ../../secrets/rclone.conf;
        format = "binary"; # full rclone config, not a yaml/dotenv key-value file
        mode = "0400";
      };

      environment.systemPackages = [ pkgs.rclone ];

      fileSystems."/mnt/mega" = {
        device = "mega:";
        fsType = "rclone";
        options = [
          "nodev"
          "nofail"
          "_netdev"
          "allow_other"
          "args2env"
          "config=${config.sops.secrets."rclone.conf".path}"
          "cache_dir=/var/cache/rclone"
          "vfs_cache_mode=full"
          "vfs_cache_max_size=50G"
          "uid=${toString config.users.users.ampersand.uid}"
          "gid=${toString config.users.groups.users.gid}"
        ];
      };
    };
}