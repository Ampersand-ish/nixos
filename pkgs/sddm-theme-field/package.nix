# Vendored SDDM "field" theme (from the CachyOS install; Qt6, needs Qt5Compat.GraphicalEffects).
{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "sddm-theme-field";
  version = "0-vendored";
  src = ./theme;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/sddm/themes/field
    cp -r . $out/share/sddm/themes/field/
  '';
}
