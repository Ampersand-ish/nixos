# CachyOS-Settings as a standalone NixOS module: sysctl, udev, systemd, ZRAM, THP, I/O tuning.
# Owns the sysctls that used to live in kernel/tuning.nix, plus ZRAM (replaces storage/zram.nix).
{ inputs, ... }:
{
  flake.modules.nixos.kernel-cachyos-settings = {
    imports = [ inputs.cachyos-settings.nixosModules.default ];

    cachyos.settings = {
      enable = true;
      # amd/nvidia GPU-specific toggles stay off (handled by modules/graphics/*).
    };
  };
}
