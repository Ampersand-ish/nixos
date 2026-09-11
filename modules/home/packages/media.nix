# Media players, codecs and colour tools (mpv/easyeffects and their plugins live in their own aspects).
{ ... }:
{
  flake.modules.homeManager.pkgs-media =
    { pkgs, ... }:
    let
      # radeonsi/radv corrupt mip levels on GFX12; loupe uses TRILINEAR scaled
      # textures, so GSK_GPU_DISABLE=mipmap can't save it - force cairo.
      loupe-cairo = pkgs.symlinkJoin {
        name = "loupe-cairo";
        paths = [ pkgs.loupe ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/loupe --set GSK_RENDERER cairo
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
        papers
      ];
    };
}
