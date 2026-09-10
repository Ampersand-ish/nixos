# NetworkManager + systemd-resolved + VPN plugins. Declarative profiles live in nm-profiles.nix (sops).
{ ... }:
{
  flake.modules.nixos.networkmanager =
    { config, pkgs, ... }:
    {
      networking.hostName = config.hostSpec.name;
      networking.networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.backend = "wpa_supplicant";
        plugins = with pkgs; [
          networkmanager-openconnect
          networkmanager-l2tp
          networkmanager-openvpn
          networkmanager-strongswan
        ];
      };

      services.resolved.enable = true;
      networking.modemmanager.enable = true;
      hardware.usb-modeswitch.enable = true;

      environment.systemPackages = with pkgs; [
        networkmanagerapplet
        openconnect
      ];
    };
}
