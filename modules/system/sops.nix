# sops-nix wiring: the host's ssh ed25519 key is the age identity; secrets/<host>.yaml is the default file.
{ inputs, ... }:
{
  flake.modules.nixos.sops =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        defaultSopsFile = ../../secrets/${config.hostSpec.name}.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
}
