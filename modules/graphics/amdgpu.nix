# AMD GPU host (future desktop): Mesa/RADV. HDR needs nothing extra beyond niri `hdr mode="auto"`.
{ ... }:
{
  flake.modules.nixos.amdgpu =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      hardware.amdgpu = {
        initrd.enable = true;
        opencl.enable = false;
        overdrive.enable = false;
      };
      services.xserver.videoDrivers = [ "amdgpu" ];
      # Enable HDMI 2.1 FRL (DC_FRL_MASK 0x400) so 4K > 60 Hz modes are exposed on HDMI.
      # Mask is a full override: default on kernel 7.2 is 0x2, so OR with the default.
      # FRL is enabled-by-default (without the param) starting with kernel 7.4.
      boot.kernelParams = [ "amdgpu.dcfeaturemask=0x402" ];
      environment.systemPackages = with pkgs; [
        nvtopPackages.amd
        radeontop
        vulkan-tools
        libva-utils
      ];
    };
}
