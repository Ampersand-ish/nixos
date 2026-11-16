# Cloud sync and remote access: AnyDesk, MEGAsync, rclone (config out-of-store), sshfs.
# MEGAsync has no autostart wiring. The rclone-mega module also mounts MEGA.
{ ... }:
{
  flake.modules.homeManager.cloud =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        anydesk
        megasync
        rclone
        sshfs
      ];

      desktop.outOfStore.rclone = "home/rclone";
    };
}
