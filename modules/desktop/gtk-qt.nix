# GTK/Qt/dconf/xsettingsd. gtk.css is an HM-owned shim that @imports noctalia.css (written by noctalia).
# Qt uses the gtk3 platform theme (qt6ct was dead under QT_QPA_PLATFORMTHEME=gtk3 already).
{ ... }:
{
  flake.modules.homeManager.gtk-qt =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        font = {
          name = "Adwaita Sans";
          size = 11;
        };
        gtk3.extraCss = ''@import url("noctalia.css");'';
        gtk4.extraCss = ''@import url("noctalia.css");'';
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      };

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "slate";
        enable-hot-corners = false;
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
      };

      services.xsettingsd = {
        enable = true;
        settings = {
          "Net/ThemeName" = "adw-gtk3-dark";
          "Net/IconThemeName" = "Adwaita";
          "Gtk/CursorThemeName" = "capitaine-cursors";
          "Net/EnableEventSounds" = 1;
          "EnableInputFeedbackSounds" = 0;
          "Xft/Antialias" = 1;
          "Xft/Hinting" = 1;
          "Xft/HintStyle" = "hintslight";
          "Xft/RGBA" = "rgb";
        };
      };

      home.packages = with pkgs; [
        nwg-look
        capitaine-cursors
      ];
    };
}
