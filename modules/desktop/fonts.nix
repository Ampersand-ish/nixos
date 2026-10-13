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
          ttf-bitstream-vera
          open-sans
          adwaita-fonts
          undefined-medium # noctalia bar font
          nerd-fonts.jetbrains-mono
          nerd-fonts.iosevka
          nerd-fonts.iosevka-term
          nerd-fonts.meslo-lg
          nerd-fonts.symbols-only
          (stdenvNoCC.mkDerivation {
            pname = "aptos-fonts";
            version = "1.0";
            src = fetchzip {
              url = "https://download.microsoft.com/download/8/6/0/860a94fa-7feb-44ef-ac79-c072d9113d69/Microsoft%20Aptos%20Fonts.zip";
              stripRoot = false;
              hash = "sha256-jkYOP5upe+zMnuQtDLCAcaG1ocbx1iHm1ygW9pqGTig=";
            };
            installPhase = ''
              mkdir -p $out/share/fonts/truetype/aptos
              find . -name '*.ttf' -exec cp {} $out/share/fonts/truetype/aptos/ \;
            '';
            meta = {
              description = "Aptos font family by Microsoft";
              platforms = pkgs.lib.platforms.all;
            };
          })
        ];
      };
    };
}
