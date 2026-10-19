# Media players, codecs and colour tools (mpv/easyeffects and their plugins live in their own aspects).
{ ... }:
{
  flake.modules.homeManager.pkgs-media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vlc
        android-mic
        android-tools # adb, for AndroidMic's USB connection mode
        handbrake
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
        papers
      ];
    };
}
