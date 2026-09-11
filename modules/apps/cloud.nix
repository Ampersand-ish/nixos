# Cloud sync and remote access: Dropbox, MEGA, AnyDesk, rclone (config out-of-store), sshfs.
{ ... }:
{
  flake.modules.homeManager.cloud =
    { pkgs, ... }:
    {
      services.dropbox.enable = true;

      home.packages = with pkgs; [
        dropbox-cli
        megasync
        anydesk
        rclone
        sshfs
      ];

      desktop.outOfStore.rclone = "home/rclone";
    };
}
