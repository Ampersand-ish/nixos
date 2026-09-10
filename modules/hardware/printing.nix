{ ... }:
{
  flake.modules.nixos.printing =
    { pkgs, ... }:
    {
      services.printing = {
        enable = true;
        drivers = with pkgs; [ gutenprint ];
      };
      hardware.sane.enable = true;
    };
}
