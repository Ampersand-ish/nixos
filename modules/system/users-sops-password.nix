# Password hash for ampersand from sops (mkpasswd -m yescrypt). Not imported by the vm host.
{ ... }:
{
  flake.modules.nixos.users-sops-password =
    { config, ... }:
    {
      sops.secrets."users/ampersand".neededForUsers = true;
      users.users.ampersand.hashedPasswordFile = config.sops.secrets."users/ampersand".path;
    };
}
