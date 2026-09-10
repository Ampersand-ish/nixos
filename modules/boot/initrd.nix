# systemd initrd (required for LUKS2+TPM2 unlock and resume-from-swapfile-on-LUKS).
{ ... }:
{
  flake.modules.nixos.initrd = {
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.tpm2.enable = true;
  };
}
