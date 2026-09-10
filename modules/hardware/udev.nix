# Custom keyboards (ZMK/VIA/QMK), uinput, i2c for ddcutil. Replaces /etc/udev/rules.d/{50-zmk,99-via}.rules.
{ ... }:
{
  flake.modules.nixos.udev = {
    hardware.keyboard.qmk.enable = true;
    hardware.uinput.enable = true;
    hardware.i2c.enable = true;
    services.udev.extraRules = ''
      # ZMK bootloader / device
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="615e", MODE="0660", GROUP="plugdev", TAG+="uaccess"
      # STM32 DFU
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0660", GROUP="plugdev", TAG+="uaccess"
      # Keychron (VIA / Link)
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0660", GROUP="input", TAG+="uaccess"
      # UF2 mass-storage bootloaders (nice!nano etc.)
      KERNEL=="sd*", ATTRS{idVendor}=="239a", ENV{ID_FS_LABEL}=="NICENANO", ENV{UDISKS_AUTO}="1"
    '';
  };
}
