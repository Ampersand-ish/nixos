# Media players, codecs and colour tools (mpv/easyeffects and their plugins live in their own aspects).
{ ... }:
{
  flake.modules.homeManager.pkgs-media =
    { pkgs, ... }:
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
        loupe
        # papers disabled: not cached in pinned nixpkgs and source build ICEs (gcc).
      ];
    };
}
