# System fonts (Stylix sets the defaults; this is the installed set).
{ ... }:
{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts = {
        fontconfig.enable = true;
        enableDefaultPackages = true;
        packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          cantarell-fonts
          dejavu_fonts
          liberation_ttf
          ttf_bitstream_vera
          open-sans
          adwaita-fonts
          undefined-medium # noctalia bar font
          nerd-fonts.jetbrains-mono
          nerd-fonts.iosevka
          nerd-fonts.iosevka-term
          nerd-fonts.meslo-lg
          nerd-fonts.symbols-only
        ];
      };
    };
}
