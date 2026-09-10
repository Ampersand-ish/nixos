# Locale/timezone/keymap as on the CachyOS install (en_IN everywhere, Amsterdam time).
{ ... }:
{
  flake.modules.nixos.locale = {
    i18n.defaultLocale = "en_IN";
    i18n.supportedLocales = [
      "en_IN/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    time.timeZone = "Europe/Amsterdam";
    console.keyMap = "us";
    services.xserver.xkb.layout = "us";
  };
}
