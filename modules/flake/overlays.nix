# Flake overlay with our own packages, plus perSystem exposure for `nix build .#<pkg>`.
{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    niri-spicy = final.callPackage ../../pkgs/niri-spicy/package.nix {
      niriSrc = inputs.niri-spicy-src;
      smithaySrc = inputs.smithay-spicy-src;
    };
    sddm-theme-field = final.callPackage ../../pkgs/sddm-theme-field/package.nix { };
  };

  perSystem =
    { pkgs, system, ... }:
    let
      ours = inputs.self.overlays.default pkgs pkgs;
    in
    {
      packages = {
        inherit (ours) niri-spicy sddm-theme-field;
      };
    };
}
