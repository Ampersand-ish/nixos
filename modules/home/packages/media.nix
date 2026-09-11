# Media players, codecs and colour tools (mpv/easyeffects and their plugins live in their own aspects).
{ ... }:
{
  flake.modules.homeManager.pkgs-media =
    { pkgs, ... }:
    let
      # GFX12-WORKAROUND: radeonsi/radv corrupt mip levels on GFX12; loupe/papers use TRILINEAR scaled
      # textures, so GSK_GPU_DISABLE=mipmap can't save them - force cairo.
      loupe-cairo = pkgs.symlinkJoin {
        name = "loupe-cairo";
        paths = [ pkgs.loupe ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/loupe --set GSK_RENDERER cairo
          # Loupe is DBusActivatable: its .service file hardcodes the raw pkgs.loupe
          # binary in Exec, which would bypass the wrapper above. Repoint it so
          # D-Bus activation also gets GSK_RENDERER=cairo.
          svc="$out/share/dbus-1/services/org.gnome.Loupe.service"
          rm -f "$svc"
          cat > "$svc" <<EOF
          [D-BUS Service]
          Name=org.gnome.Loupe
          Exec=$out/bin/loupe --gapplication-service
          EOF
        '';
      };
      papers-cairo = pkgs.symlinkJoin {
        name = "papers-cairo";
        paths = [ pkgs.papers ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for bin in papers papers-previewer papers-thumbnailer; do
            [ -e "$out/bin/$bin" ] && wrapProgram "$out/bin/$bin" --set GSK_RENDERER cairo
          done
        '';
      };
    in
    {
      home.packages = with pkgs; [
        vlc
        handbrake
        lollypop
        ffmpegthumbnailer
        chromaprint
        libdvdcss
        libopenraw
        argyllcms
        ddcutil
        pavucontrol
        showtime
        decibels
        snapshot
        loupe-cairo
        papers-cairo
      ];
    };
}
