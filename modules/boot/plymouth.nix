# Plymouth boot splash. The theme stays under Stylix's control, which
# renders its splash with the NixOS snowflake logo by default
# (stylix.targets.plymouth.logo).
{ ... }:
{
  flake.modules.nixos.plymouth = {
    boot.plymouth.enable = true;
  };
}