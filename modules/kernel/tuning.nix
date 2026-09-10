# Kernel params, sysctl and scheduling tweaks carried over from CachyOS defaults.
{ ... }:
{
  flake.modules.nixos.kernel-tuning =
    { pkgs, ... }:
    {
      boot.kernelParams = [
        "nowatchdog"
        "8250.nr_uarts=0"
        "nvme_core.default_ps_max_latency_us=0"
      ];

      boot.kernel.sysctl = {
        "vm.swappiness" = 100;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.dirty_background_bytes" = 67108864;
        "vm.page-cluster" = 0;
        "vm.dirty_writeback_centisecs" = 1500;
        "kernel.nmi_watchdog" = 0;
        "kernel.printk" = "3 3 3 3";
        "kernel.kptr_restrict" = 2;
        "net.core.netdev_max_backlog" = 4096;
        "fs.file-max" = 2097152;
      };

      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      # sched_ext schedulers are available on CachyOS kernels; off by default (was not used on Arch).
      services.scx = {
        enable = false;
        scheduler = "scx_lavd";
      };
    };
}
