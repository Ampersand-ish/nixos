# Steam + compat tools (Proton-GE, Proton-CachyOS), gamemode, gamescope, protontricks.
# Equivalent of cachyos-gaming-meta; launchers/wine live in home (modules/home/packages/gaming.nix).
{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        protontricks.enable = true;
        extraCompatPackages = [
          pkgs.proton-ge-bin
          inputs.nix-proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.proton-cachyos
        ];
        extraPackages = with pkgs; [
          mangohud
          gamemode
        ];
      };
      programs.gamemode = {
        enable = true;
        settings.general.renice = 10;
      };
      programs.gamescope.enable = true;
      hardware.steam-hardware.enable = true;
      fonts.packages = with pkgs; [ wqy_zenhei ];
    };
}
