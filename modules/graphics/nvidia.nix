# NVIDIA (open kernel modules) with the HDR/deep-colour chain from the CachyOS install.
# Host is in MUX/dGPU mode: PRIME offload is forced off (nixos-hardware ga503 enables it).
{ ... }:
{
  flake.modules.nixos.nvidia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        open = true;
        modesetting.enable = true;
        nvidiaSettings = true;
        nvidiaPersistenced = true;
        dynamicBoost.enable = true;
        powerManagement.enable = true; # PreserveVideoMemoryAllocations + nvidia-{suspend,hibernate,resume}
        powerManagement.finegrained = false;
        prime = {
          amdgpuBusId = "PCI:7:0:0";
          nvidiaBusId = "PCI:1:0:0";
          offload.enable = lib.mkForce false;
          offload.enableOffloadCmd = lib.mkForce false;
          sync.enable = false;
        };
      };

      # Module options (modprobe.d). RegistryDwords = 30-bit colour + panel dithering for the HDR path.
      boot.extraModprobeConfig = ''
        options nvidia NVreg_RegistryDwords="RM30BitColor=1;RMFlatPanelDithering=1;RMFlatPanelDitheringMode=4;"
        options nvidia NVreg_EnableS0ixPowerManagement=1 NVreg_DynamicPowerManagement=0x02
        options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
        options nvidia-modeset hdmi_deepcolor=1
      '';

      # Duplicated on the cmdline on purpose: matches the CachyOS install and is verifiable in /proc/cmdline.
      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "nvidia-modeset.hdmi_deepcolor=1"
      ];
      boot.blacklistedKernelModules = [ "nouveau" ];
      # NVIDIA modules deliberately NOT in the initrd (hibernate/resume); mirrors the dracut omit_drivers.

      environment.sessionVariables.__GL_ALLOW_UNOFFICIAL_PROTOCOL = "1";

      # suspend-then-hibernate hook (nixpkgs only wires suspend/hibernate/resume).
      systemd.services.nvidia-suspend-then-hibernate = {
        description = "NVIDIA system suspend-then-hibernate actions";
        path = [ pkgs.kbd ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.mkForce "${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh suspend";
        };
        before = [ "systemd-suspend-then-hibernate.service" ];
        requiredBy = [ "systemd-suspend-then-hibernate.service" ];
      };
      systemd.services.nvidia-resume = {
        after = [ "systemd-suspend-then-hibernate.service" ];
        requiredBy = [ "systemd-suspend-then-hibernate.service" ];
      };

      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
        libva-utils
        vulkan-tools
      ];
    };
}
