# Qt/GDK graphic loaders. The NixOS qt module sets profile-relative QT_PLUGIN_PATH,
# which is what makes profile-installed plugins visible to *every* Qt app — HM's
# qt.enable doesn't do that. Without it, nixpkgs Qt apps only see plugins from their
# own build inputs and render SVGs clipped/missing. Same story for unwrapped GTK apps:
# they get no composed loaders.cache, so librsvg's SVG pixbuf loader must be provided
# via GDK_PIXBUF_MODULE_FILE (wrapped GTK apps set their own, which takes precedence).
{ ... }:
{
  flake.modules.nixos.qt-loaders =
    { pkgs, lib, ... }:
    let
      # gdk-pixbuf + librsvg loaders merged into one tree, then a cache generated over it.
      gdk-pixbuf-loaders = pkgs.buildEnv {
        name = "gdk-pixbuf-loaders";
        paths = [
          pkgs.gdk-pixbuf
          pkgs.librsvg
        ];
        # both paths ship a loaders.cache; postBuild overwrites it, so collisions are fine.
        ignoreCollisions = true;
        pathsToLink = [ "/lib/gdk-pixbuf-2.0" ];
        postBuild = ''
          rm -f $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
          ${lib.getDev pkgs.gdk-pixbuf}/bin/gdk-pixbuf-query-loaders \
            $out/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so \
            > $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
        '';
      };
    in
    {
      # NixOS-side only: HM (gtk-qt.nix) owns platformTheme/style, so leave those null here.
      qt.enable = true;

      environment.systemPackages = with pkgs; [
        kdePackages.qtsvg
        libsForQt5.qtsvg
        librsvg
      ];

      environment.sessionVariables.GDK_PIXBUF_MODULE_FILE =
        "${gdk-pixbuf-loaders}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };
}
