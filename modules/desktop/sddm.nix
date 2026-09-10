# SDDM (Wayland) with the vendored "field" theme; niri is the default session.
{ ... }:
{
  flake.modules.nixos.sddm =
    { pkgs, ... }:
    {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "field";
        extraPackages = with pkgs.kdePackages; [
          qtsvg
          qt5compat # Qt5Compat.GraphicalEffects used by Main.qml
          qtdeclarative # Qt.labs.folderlistmodel
        ];
      };
      services.displayManager.defaultSession = "niri";
      environment.systemPackages = [ pkgs.sddm-theme-field ];
    };
}
