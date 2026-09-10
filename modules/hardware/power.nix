{ ... }:
{
  flake.modules.nixos.power =
    { pkgs, ... }:
    {
      powerManagement.enable = true;
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
      environment.systemPackages = with pkgs; [ powertop ];
    };
}
