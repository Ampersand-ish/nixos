# zram swap sized to RAM, zstd, high priority (the btrfs swapfile at prio 0 is for hibernation).
{ ... }:
{
  flake.modules.nixos.zram = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
      priority = 100;
    };
  };
}
