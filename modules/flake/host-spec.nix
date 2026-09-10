# Per-host facts. Set by the host module, read by aspects (and by home-manager via osConfig.hostSpec).
{ ... }:
{
  flake.modules.nixos.host-spec =
    { lib, ... }:
    {
      options.hostSpec = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Host name (also used for secrets/<name>.yaml).";
        };
        osDisk = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "/dev/disk/by-id/... of the ONLY disk disko may format.";
        };
        espSize = lib.mkOption {
          type = lib.types.str;
          default = "2G";
        };
        swapSize = lib.mkOption {
          type = lib.types.str;
          default = "20G";
          description = "btrfs swapfile size (hibernation image target).";
        };
        kernelVariant = lib.mkOption {
          type = lib.types.str;
          default = "latest";
          example = "latest-x86_64-v3";
          description = "Suffix of pkgs.cachyosKernels.linuxPackages-cachyos-<variant>.";
        };
        gpu = lib.mkOption {
          type = lib.types.enum [
            "nvidia"
            "amdgpu"
            "virtio"
          ];
          description = "Primary GPU driver family; selects the graphics aspect behaviour.";
        };
        resumeOffset = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Output of `btrfs inspect-internal map-swapfile -r /swap/swapfile` (post-install).";
        };
      };
    };
}
