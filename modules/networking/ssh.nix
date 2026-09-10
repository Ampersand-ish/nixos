# sshd enabled (host key doubles as the sops age identity); key-only auth, port closed in the firewall.
{ ... }:
{
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
