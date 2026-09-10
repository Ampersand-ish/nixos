# Nix daemon settings, binary caches, nh (nix helper) as the rebuild/cleanup front-end.
{ ... }:
{
  flake.modules.nixos.nix =
    { pkgs, ... }:
    {
      nix = {
        channel.enable = false;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          trusted-users = [
            "root"
            "@wheel"
          ];
          substituters = [
            "https://cache.nixos.org"
            "https://niri.cachix.org"
            "https://attic.xuyh0120.win/lantian"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "niri.cachix.org-1:Xfjzn4R91yzPPQd4r7s06DH7gvz/OEApKd68GYcIQwM="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };

      programs.nh = {
        enable = true;
        flake = "/home/ampersand/Desktop/nixos";
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep 5 --keep-since 7d";
        };
      };

      # LazyVim/Mason and other prebuilt binaries need a dynamic loader.
      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        git
        nixfmt-rfc-style
        nix-output-monitor
        nvd
      ];
    };
}
