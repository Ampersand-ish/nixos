# Plain systemd-boot: the vm host, or a fallback for a host without Secure Boot keys yet.
{ ... }:
{
  flake.modules.nixos.systemd-boot = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 3;
  };
}
