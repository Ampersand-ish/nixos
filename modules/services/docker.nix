{ ... }:
{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = false; # socket-activated, as on CachyOS
      };
      environment.systemPackages = with pkgs; [ docker-compose ];
    };
}
