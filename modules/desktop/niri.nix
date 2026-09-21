# niri (spicy fork) as the compositor. System side: niri-flake module with our package.
# Home side: raw KDL config (spicy-only nodes are not expressible in niri-flake's typed settings),
# validated at build time with the spicy binary. Per-host output blocks come via desktop.niri.outputs.
{ inputs, ... }:
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      imports = [ inputs.niri-flake.nixosModules.niri ];
      programs.niri = {
        enable = true;
        package = pkgs.niri-spicy;
      };
      niri-flake.cache.enable = false; # substituters are managed centrally in system/nix.nix
      # noctalia provides the polkit agent; disable niri-flake's KDE agent.
      systemd.user.services.niri-flake-polkit.enable = false;
      environment.systemPackages = with pkgs; [
        xwayland-satellite
        wl-clipboard
      ];
    };

  flake.modules.homeManager.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.desktop.niri.outputs = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Raw KDL `output` blocks contributed by the host.";
      };

      config = {
        programs.niri.package = pkgs.niri-spicy;
        programs.niri.config = lib.concatStringsSep "\n" [
          (builtins.readFile ../../home/niri/config.kdl)
          "// ---- host outputs (desktop.niri.outputs) ----"
          config.desktop.niri.outputs
          "// ---- noctalia colour overrides, written at runtime ----"
          ''include optional=true "noctalia.kdl"''
        ];
        # niri-flake auto-imports its stylix target; noctalia owns colours.
        stylix.targets.niri.enable = false;
      };
    };
}
