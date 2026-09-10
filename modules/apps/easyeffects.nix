# EasyEffects audio processing as a user service, presets kept out-of-store, extra LV2/LADSPA plugins.
{ ... }:
{
  flake.modules.homeManager.easyeffects =
    { pkgs, ... }:
    {
      services.easyeffects.enable = true;
      desktop.outOfStore.easyeffects = "home/easyeffects";
      home.packages = with pkgs; [
        calf
        lsp-plugins
        zam-plugins
      ];
    };
}
