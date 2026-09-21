# Cloud sync and remote access: MEGA, AnyDesk, rclone (config out-of-store), sshfs.
{ ... }:
{
  flake.modules.homeManager.cloud =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        megasync
        anydesk
        rclone
        sshfs
      ];

      desktop.outOfStore.rclone = "home/rclone";
    };
}
