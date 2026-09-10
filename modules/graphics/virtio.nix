# QEMU guest graphics for the vm host.
{ ... }:
{
  flake.modules.nixos.virtio = {
    hardware.graphics.enable = true;
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
  };
}
