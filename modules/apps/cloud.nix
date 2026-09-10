# Cloud sync and remote access: Dropbox, MEGA, Remmina, AnyDesk, rclone (config out-of-store), sshfs.
{ ... }:
{
  flake.modules.homeManager.cloud =
    { pkgs, ... }:
    {
      services.dropbox.enable = true;

      services.megasync = {
        enable = true;
        forceWayland = true;
      };

      services.remmina = {
        enable = true;
        systemdService.enable = true;
        addRdpMimeTypeAssoc = true;
      };

      home.packages = with pkgs; [
        dropbox-cli
        anydesk
        rclone
        sshfs
      ];

      desktop.outOfStore.rclone = "home/rclone";
    };
}
