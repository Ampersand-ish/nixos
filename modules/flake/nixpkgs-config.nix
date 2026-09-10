# nixpkgs settings shared by all hosts: unfree predicate + overlays.
{ inputs, config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.nixpkgs-config =
    { lib, ... }:
    {
      # ollama-cuda pulls a large CUDA closure with many unfree attr names; a predicate is impractical.
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.niri-flake.overlays.niri
        flakeConfig.flake.overlays.default
      ];
    };
}
