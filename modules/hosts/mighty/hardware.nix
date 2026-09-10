# Hardware facts for mighty (ROG Strix B860-I Gaming WiFi, LGA1851 Core Ultra, RX 9070 XT).
# Re-check boot.initrd.availableKernelModules against nixos-generate-config after the first install.
{ inputs, ... }:
{
  flake.modules.nixos.mighty-hardware =
    { lib, ... }:
    {
      imports = with inputs.nixos-hardware.nixosModules; [
        common-cpu-intel-cpu-only # iGPU stays out of the way of the RX 9070 XT
        common-gpu-amd
        common-pc-ssd
      ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      boot.kernelModules = [
        "kvm-intel"
        "uinput"
        "i2c-dev"
      ];
      hardware.cpu.intel.updateMicrocode = true;
    };
}
