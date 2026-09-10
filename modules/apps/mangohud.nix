# MangoHud overlay: minimal fps/gpu/ram/vram readout without margins or background.
{ ... }:
{
  flake.modules.homeManager.mangohud =
    { ... }:
    {
      # Stylix's mangohud target sets alpha/font/colours and conflicts with our transcribed settings.
      stylix.targets.mangohud.enable = false;

      programs.mangohud = {
        enable = true;
        settings = {
          legacy_layout = 0;
          fps = 1;
          cpu_stats = 0;
          gpu_stats = 1;
          ram = 1;
          vram = 1;
          engine_version = 0;
          hud_no_margin = true;
          background_alpha = 0;
          alpha = 1;
        };
      };
    };
}
