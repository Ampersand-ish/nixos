# Hardware facts for moonwhite (what nixos-generate-config --no-filesystems would emit).
# Re-check boot.initrd.availableKernelModules against the generated file after the first install.
{ ... }:
{
  flake.modules.nixos.moonwhite-hardware =
    { lib, ... }:
    {
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
        "rtsx_pci_sdmmc"
      ];
      boot.kernelModules = [
        "kvm-amd"
        "uinput"
        "i2c-dev"
      ];
      hardware.cpu.amd.updateMicrocode = true;
    };
}
