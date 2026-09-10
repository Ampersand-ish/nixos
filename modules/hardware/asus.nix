# ASUS ROG Zephyrus G15 (GA503RW): nixos-hardware profile, asusd, supergfxd (MUX in dGPU mode).
{ inputs, ... }:
{
  flake.modules.nixos.asus =
    { pkgs, ... }:
    {
      imports = with inputs.nixos-hardware.nixosModules; [
        asus-zephyrus-ga503
        asus-battery
        common-cpu-amd-pstate
      ];

      hardware.asus.battery.chargeUpto = 80;

      services.asusd = {
        enable = true;
        asusdConfig.source = ./asusd/asusd.ron;
        fanCurvesConfig.source = ./asusd/fan_curves.ron;
        auraConfigs."19b6".source = ./asusd/aura_19b6.ron;
      };

      services.supergfxd = {
        enable = true;
        settings = {
          mode = "AsusMuxDgpu";
          vfio_enable = false;
          vfio_save = false;
          always_reboot = false;
          no_logind = false;
          logout_timeout_s = 180;
          hotplug_type = "None";
        };
      };

      services.switcherooControl.enable = true;

      environment.systemPackages = with pkgs; [
        asusctl
        supergfxctl
      ];
    };
}
