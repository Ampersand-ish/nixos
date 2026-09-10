# Stylix owns the *skeleton* (fonts, cursor, fallback base16 scheme, opacity).
# Noctalia owns *colours* at runtime, so every target noctalia templates is disabled on the HM side.
{ inputs, ... }:
{
  flake.modules.nixos.stylix =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = {
        enable = true;
        image = ../../home/wallpapers/planets/wallhaven-5y5dg7.jpg;
        base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/oxocarbon-dark.yaml";
        polarity = "dark";
        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.adwaita-fonts;
            name = "Adwaita Sans";
          };
          serif = {
            package = pkgs.noto-fonts;
            name = "Noto Serif";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            applications = 11;
            desktop = 11;
            popups = 11;
            terminal = 12;
          };
        };
        cursor = {
          package = pkgs.capitaine-cursors;
          name = "capitaine-cursors";
          size = 36;
        };
        opacity = {
          applications = 1.0;
          desktop = 1.0;
          popups = 1.0;
          terminal = 1.0;
        };
        homeManagerIntegration.followSystem = true;
        homeManagerIntegration.autoImport = true;
      };
    };

  flake.modules.homeManager.stylix = {
    stylix.targets = {
      # noctalia-templated (or noctalia-conflicting) targets -> OFF
      gtk.enable = false;
      qt.enable = false;
      ghostty.enable = false;
      btop.enable = false;
      neovim.enable = false;
      bat.enable = false;
      opencode.enable = false;
      vesktop.enable = false;
      vencord.enable = false;
      gnome.enable = false;
      mpv.enable = false;
      zed.enable = false;
      # kept ON (defaults): fontconfig, font-packages, fzf, mangohud, cursor
    };
  };
}
