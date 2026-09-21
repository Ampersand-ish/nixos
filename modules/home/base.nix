# Home-manager base: flake location, out-of-store symlink table, and seeding of the files
# noctalia/apps generate at runtime (so validators and @import shims never hit a missing file).
{ ... }:
{
  flake.modules.homeManager.base =
    { config, lib, ... }:
    {
      options.desktop = {
        flakeDir = lib.mkOption {
          type = lib.types.str;
          default = "/home/ampersand/Desktop/nixos";
          description = "Checkout of this flake; out-of-store symlinks point into it.";
        };
        outOfStore = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            nvim = "home/nvim";
          };
          description = "xdg.configFile name -> repo-relative directory, linked mutably via mkOutOfStoreSymlink.";
        };
      };

      config = {
        home.stateVersion = "26.05";

        xdg.enable = true;
        xdg.configFile = lib.mapAttrs (_: rel: {
          source = config.lib.file.mkOutOfStoreSymlink "${config.desktop.flakeDir}/${rel}";
        }) config.desktop.outOfStore;

        home.file."Pictures/Wallpapers".source =
          config.lib.file.mkOutOfStoreSymlink "${config.desktop.flakeDir}/home/wallpapers";

        home.activation.seedGenerated = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                    c="${config.xdg.configHome}"
                    mkdir -p "$c/niri" "$c/niri/dms" "$c/ghostty/themes" "$c/btop/themes" "$c/gtk-3.0" "$c/gtk-4.0" "$c/bat/themes"
                    [ -e "$c/niri/noctalia.kdl" ] || : > "$c/niri/noctalia.kdl"
                    [ -e "$c/gtk-3.0/noctalia.css" ] || : > "$c/gtk-3.0/noctalia.css"
                    [ -e "$c/gtk-4.0/noctalia.css" ] || : > "$c/gtk-4.0/noctalia.css"
                    [ -e "$c/ghostty/themes/noctalia" ] || printf 'background = 1e1e2e\nforeground = cdd6f4\n' > "$c/ghostty/themes/noctalia"
                    [ -e "$c/niri/dms/colors.kdl" ] || : > "$c/niri/dms/colors.kdl"
                    # dms/layout.kdl is DMS's source of truth for the niri xray setting: it
                    # reads the file once, and treats "xray false" as the persisted choice.
                    # Create it if absent (DMS regenerates the rest on next start), then
                    # append the xray-off rules whenever the marker is missing.
                    [ -e "$c/niri/dms/layout.kdl" ] || : > "$c/niri/dms/layout.kdl"
                    grep -q "xray false" "$c/niri/dms/layout.kdl" || cat >> "$c/niri/dms/layout.kdl" <<'KDL'

          layer-rule {
              background-effect {
                  xray false
              }
          }

          window-rule {
              match app-id="^com.danklinux.dms$"
              background-effect {
                  xray false
              }
          }
          KDL
                    [ -e "$c/niri/dms/alttab.kdl" ] || : > "$c/niri/dms/alttab.kdl"
                    [ -e "$c/niri/dms/binds.kdl" ] || : > "$c/niri/dms/binds.kdl"
                    [ -e "$c/chrome-flags.conf" ] || printf '%s\n' \
                      '# chrome-hdr: toggle with `chrome-hdr on|off`' \
                      '--disable-features=WaylandWpColorManagerV1' > "$c/chrome-flags.conf"
        '';

        # Steam's bin_steam.sh requires ~/.steam/steam to be a symlink to the data dir.
        # A real directory there (e.g. left by a manual steamui skin install) breaks the
        # bootstrap with "Couldn't set up Steam data". Repair it: move any steamui content
        # into the data dir, drop the stray dir, then relink.
        home.activation.repairSteamDataLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          data="''${XDG_DATA_HOME:-$HOME/.local/share}/Steam"
          link="$HOME/.steam/steam"

          if [ -e "$link" ] && [ ! -L "$link" ]; then
            if [ -d "$link/steamui" ]; then
              mkdir -p "$data/steamui"
              cp -a "$link/steamui/." "$data/steamui/"
            fi
            rm -rf "$link"
          fi

          if [ ! -e "$link" ]; then
            mkdir -p "$HOME/.steam"
            ln -s "$data" "$link"
          fi
        '';
      };
    };
}
