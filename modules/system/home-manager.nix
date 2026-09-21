# home-manager as a NixOS module. Hosts list their HM aspects in home-manager.users.ampersand.imports.
{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      extraSpecialArgs = {
        inherit inputs;
      };
      sharedModules = [
        inputs.noctalia-shell.homeModules.default
        inputs.sops-nix.homeManagerModules.sops
      ];
      users.ampersand = {
        home.username = "ampersand";
        home.homeDirectory = "/home/ampersand";
        programs.home-manager.enable = true;
      };
    };
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
      "/share/zsh"
    ];
  };
}
