# TPM2 support in the systemd initrd (required for LUKS2+TPM2 unlock). systemd is the only initrd in nixpkgs now.
{ ... }:
{
  flake.modules.nixos.initrd = {
    boot.initrd.systemd.tpm2.enable = true;
  };
}
