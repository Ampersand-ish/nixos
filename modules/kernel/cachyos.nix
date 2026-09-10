# CachyOS kernel from xddxdd/nix-cachyos-kernel (pinned overlay => binary cache hits).
{ inputs, ... }:
{
  flake.modules.nixos.kernel-cachyos =
    { config, pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
      boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-${config.hostSpec.kernelVariant}";
    };
}
