# Secure Boot via lanzaboote, signing with the existing sbctl keys at /var/lib/sbctl.
{ inputs, ... }:
{
  flake.modules.nixos.lanzaboote =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.systemd-boot.editor = false;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot";
      boot.loader.timeout = 3;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = 8;
      };

      environment.systemPackages = with pkgs; [
        sbctl
        efibootmgr
      ];
    };
}
