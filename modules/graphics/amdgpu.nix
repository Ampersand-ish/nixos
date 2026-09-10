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
      environment.systemPackages = with pkgs; [
        nvtopPackages.amd
        radeontop
        vulkan-tools
        libva-utils
      ];
    };
}
