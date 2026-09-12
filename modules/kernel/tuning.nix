# Kernel params and scheduling tweaks carried over from CachyOS defaults.
# (sysctls live in cachyos-settings; see modules/kernel/cachyos-settings.nix)
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
