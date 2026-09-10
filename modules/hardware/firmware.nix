{ ... }:
{
  flake.modules.nixos.firmware = {
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;
    services.fwupd.enable = true;
  };
}
