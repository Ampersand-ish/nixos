# NetworkManager profiles provisioned from sops (secrets/nm.env). Not imported by the vm host.
{ ... }:
{
  flake.modules.nixos.nm-profiles =
    { config, ... }:
    {
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ config.sops.secrets."nm.env".path ];
        profiles = {
          home-wifi = {
            connection = {
              id = "home-wifi";
              type = "wifi";
              autoconnect = true;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$HOME_SSID";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
        };
      };
      sops.secrets."nm.env" = {
        sopsFile = ../../secrets/nm.env;
        format = "dotenv";
        key = "";
      };
    };
}
