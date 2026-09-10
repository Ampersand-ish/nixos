# Default applications + XDG user dirs. Portal config is system-side (desktop/portals.nix).
{ ... }:
{
  flake.modules.homeManager.portals-mime =
    { config, ... }:
    let
      chrome = [ "google-chrome.desktop" ];
    in
    {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
          "text/plain" = [ "org.gnome.TextEditor.desktop" ];
          "application/pdf" = [ "org.gnome.Papers.desktop" ];
          "image/png" = [ "org.gnome.Loupe.desktop" ];
          "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
          "image/webp" = [ "org.gnome.Loupe.desktop" ];
          "image/gif" = [ "org.gnome.Loupe.desktop" ];
          "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
          "video/mp4" = [ "mpv.desktop" ];
          "video/x-matroska" = [ "mpv.desktop" ];
          "video/webm" = [ "mpv.desktop" ];
          "audio/mpeg" = [ "org.gnome.Lollypop.desktop" ];
          "audio/flac" = [ "org.gnome.Lollypop.desktop" ];
          "audio/ogg" = [ "org.gnome.Lollypop.desktop" ];
          "text/html" = chrome;
          "x-scheme-handler/http" = chrome;
          "x-scheme-handler/https" = chrome;
          "x-scheme-handler/about" = chrome;
          "x-scheme-handler/unknown" = chrome;
          "x-scheme-handler/kdeconnect" = [ "org.kde.kdeconnect.app.desktop" ];
          "x-scheme-handler/discord" = [ "vesktop.desktop" ];
          "application/zip" = [ "org.gnome.FileRoller.desktop" ];
          "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        };
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        videos = "${config.home.homeDirectory}/Videos";
        publicShare = "${config.home.homeDirectory}/Public";
        templates = "${config.home.homeDirectory}/Templates";
      };
    };
}
