# OpenVPN client for NetworkManager (on-demand: `nmcli connection up vpn`).
# The full .ovpn bundle (embeds the client private key) and the credentials
# live in sops (secrets/vpn.ovpn binary, secrets/vpn.env dotenv). At boot the
# public certs are split out of the decrypted bundle into /run/openvpn-nm for
# the NM openvpn plugin; the profile references them, never the secret file.
{ ... }:
{
  flake.modules.nixos.openvpn =
    { config, pkgs, ... }:
    {
      sops.secrets."vpn.ovpn" = {
        sopsFile = ../../secrets/vpn.ovpn;
        format = "binary";
      };
      sops.secrets."vpn.env" = {
        sopsFile = ../../secrets/vpn.env;
        format = "dotenv";
        key = "";
      };
      networking.networkmanager.ensureProfiles.environmentFiles = [
        config.sops.secrets."vpn.env".path
      ];

      systemd.services.openvpn-nm-extract = {
        description = "Split OpenVPN certs out of the sops-decrypted .ovpn bundle";
        before = [ "NetworkManager.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          # systemd removes the RuntimeDirectory when a oneshot deactivates;
          # without this the certs are erased right after extraction.
          RuntimeDirectoryPreserve = "yes";
          RuntimeDirectory = "openvpn-nm";
          RuntimeDirectoryMode = "0700";
          ExecStart = pkgs.writeShellScript "openvpn-nm-extract" ''
            set -euo pipefail
            src=${config.sops.secrets."vpn.ovpn".path}
            dst=/run/openvpn-nm
            ${pkgs.gawk}/bin/awk '/<ca>/{f=1; next} /<\/ca>/{f=0} f' "$src" > "$dst/ca.pem"
            ${pkgs.gawk}/bin/awk '/<cert>/{f=1; next} /<\/cert>/{f=0} f' "$src" > "$dst/cert.pem"
            ${pkgs.gawk}/bin/awk '/<key>/{f=1; next} /<\/key>/{f=0} f' "$src" > "$dst/key.pem"
            chmod 600 "$dst"/ca.pem "$dst"/cert.pem "$dst"/key.pem
          '';
        };
      };

      networking.networkmanager.ensureProfiles.profiles.vpn = {
        connection = {
          id = "vpn";
          type = "vpn";
          autoconnect = false;
        };
        # NOTE: vpn.data is a dict, but the keyfile plugin does NOT accept the
        # one-line "data=k=v;k=v;" serialization (that's the D-Bus/nmcli format).
        # Each dict key must be a separate variable under [vpn] — see
        # nm-settings-keyfile(5), Table "vpn setting".
        vpn = {
          service-type = "org.freedesktop.NetworkManager.openvpn";
          remote = "106.51.70.63:1194:udp";
          float = "yes";
          connection-type = "password-tls";
          username = "$VPN_USER";
          ca = "/run/openvpn-nm/ca.pem";
          cert = "/run/openvpn-nm/cert.pem";
          key = "/run/openvpn-nm/key.pem";
          cipher = "AES-128-CBC";
          comp-lzo = "no";
        };
        vpn-secrets = {
          password = "$VPN_PASS";
        };
      };
    };
}
