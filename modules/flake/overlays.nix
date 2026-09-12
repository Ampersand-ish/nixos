# Flake overlay with our own packages, plus perSystem exposure for `nix build .#<pkg>`.
{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    niri-spicy = final.callPackage ../../pkgs/niri-spicy/package.nix {
      niriSrc = inputs.niri-spicy-src;
      smithaySrc = inputs.smithay-spicy-src;
    };
    sddm-theme-field = final.callPackage ../../pkgs/sddm-theme-field/package.nix { };

    # 0.8.2 regressed Steam popup/context menus (open then instantly dismiss).
    # Pin to 0.8.1 until upstream lands a fix. cargoDeps must be rebuilt alongside
    # src (overriding cargoHash alone keeps the old vendor derivation).
    xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
      version = "0.8.1";
      src = final.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xwayland-satellite";
        tag = "v0.8.1";
        hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
      };
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        name = "xwayland-satellite-0.8.1-vendor";
        src = final.fetchFromGitHub {
          owner = "Supreeeme";
          repo = "xwayland-satellite";
          tag = "v0.8.1";
          hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
        };
        hash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
      };
      cargoHash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
    });
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
