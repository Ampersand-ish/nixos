# TPM2 userland (systemd-cryptenroll, tpm2-tools for the keyring unlock, pkcs11).
{ ... }:
{
  flake.modules.nixos.tpm = {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
      tssGroup = "tss";
    };
  };
}
