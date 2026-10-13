# Flake overlay with our own packages, plus perSystem exposure for `nix build .#<pkg>`.
{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    niri-spicy = final.callPackage ../../pkgs/niri-spicy/package.nix {
      niriSrc = inputs.niri-spicy-src;
      smithaySrc = inputs.smithay-spicy-src;
    };
    sddm-theme-field = final.callPackage ../../pkgs/sddm-theme-field/package.nix { };

    # opencode from upstream (sst/opencode) for latest releases. Their overlay's
    # committed hashes.json drifts whenever our (followed) nixpkgs bumps bun, so
    # call their packaging files directly and pass the real output hash ourselves.
    opencode =
      let
        node-modules = final.callPackage (inputs.opencode + "/nix/node_modules.nix") {
          rev = builtins.substring 0 7 inputs.opencode.rev;
          hash = "sha256-41b9FJaGRnezYwKLyBTHlJw69OX4bBP8kF6mRKqbbVQ=";
        };
      in
      (final.callPackage (inputs.opencode + "/nix/opencode.nix") {
        node_modules = node-modules;
      }).overrideAttrs (old: {
        # build.ts imports ../../../script/native-arch, but upstream's
        # node_modules.nix fileset omits the root script/ dir.
        src = inputs.opencode;
      });

    # Zotero 10.0.4 in nixpkgs breaks against Firefox ESR 153 (Zotero's omni.ja
    # patch script targets ESR 140) -- see the nixpkgs-zotero input in flake.nix.
    zotero = inputs.nixpkgs-zotero.legacyPackages.${final.system}.zotero;

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
