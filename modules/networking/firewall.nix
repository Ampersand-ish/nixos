# Default-deny inbound (was ufw). kdeconnect opens its own port range.
{ ... }:
{
  flake.modules.nixos.firewall = {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    programs.kdeconnect.enable = true;
  };
}
