# Music Player Daemon: socket-activated user service with PipeWire output, state under $XDG_DATA_HOME/mpd.
{ ... }:
{
  flake.modules.homeManager.mpd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [ pkgs.cantata ];

      # mpd-mpris starts at login and holds a connection, so MPD runs from login on
      # (startWhenNeeded below stays, but is effectively moot with MPRIS enabled).
      services.mpd-mpris.enable = true;

      # Bind the MPD stack to the graphical session: stops on logout instead of
      # surviving it (the default, since logind.killUserProcesses is false).
      systemd.user = {
        sockets.mpd.Unit = {
          PartOf = [ "graphical-session.target" ];
          WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
        services.mpd.Unit.PartOf = [ "graphical-session.target" ];
        services.mpd-mpris.Unit = {
          PartOf = [ "graphical-session.target" ];
          WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
      };

      services.mpd = {
        enable = true;
        # ~/Music is a symlink to /mnt/Files/Music on the desktop
        musicDirectory = "${config.home.homeDirectory}/Music";
        dataDir = "${config.xdg.dataHome}/mpd";
        playlistDirectory = "${config.xdg.dataHome}/mpd/playlists";
        dbFile = "${config.xdg.dataHome}/mpd/database";
        network = {
          listenAddress = "any";
          startWhenNeeded = true;
        };
        # HM already writes music_directory, playlist_directory, db_file, state_file and sticker_file.
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "PipeWire"
          }
        '';
      };
    };
}
