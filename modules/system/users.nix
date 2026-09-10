# The single interactive user. Password comes from sops (users-sops-password) or initialPassword (vm).
{ ... }:
{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      users.mutableUsers = false;
      programs.zsh.enable = true;
      users.groups.plugdev = { };
      users.users.ampersand = {
        isNormalUser = true;
        uid = 1000;
        description = "Mouli Rajesh";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "input"
          "video"
          "storage"
          "docker"
          "i2c"
          "plugdev"
          "tss"
          "dialout"
          "rfkill"
          "lp"
          "scanner"
          "uinput"
          "gamemode"
        ];
      };
      security.sudo.wheelNeedsPassword = true;
    };
}
