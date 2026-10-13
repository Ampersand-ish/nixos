# Cloud sync and remote access: AnyDesk, rclone (config out-of-store), sshfs.
# megasync removed: the rclone-mega module mounts MEGA directly; the app has no
# autostart wiring, but its tray app is redundant next to the system mount.
{ ... }:
{
  flake.modules.homeManager.cloud =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        anydesk
        rclone
        sshfs
      ];

      desktop.outOfStore.rclone = "home/rclone";
    };
}
