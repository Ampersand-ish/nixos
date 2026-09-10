# Google Chrome wrapped to read ~/.config/chrome-flags.conf, plus the `chrome-hdr` toggle script.
{ ... }:
{
  flake.modules.homeManager.chrome =
    { pkgs, ... }:
    let
      # Toggles `--disable-features=WaylandWpColorManagerV1` in chrome-flags.conf (chrome-hdr on|off|toggle|status).
      chrome-hdr = pkgs.writeShellApplication {
        name = "chrome-hdr";
        runtimeInputs = with pkgs; [
          coreutils
          gnugrep
          gnused
          procps
        ];
        # writeShellApplication supplies its own shebang; drop the script's.
        text = builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
          builtins.readFile ../../home/scripts/chrome-hdr
        );
      };

      chrome-wrapped = pkgs.symlinkJoin {
        name = "google-chrome-flags";
        paths = [ pkgs.google-chrome ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          # Replace the launcher with a wrapper that appends every non-comment, non-empty
          # line of $XDG_CONFIG_HOME/chrome-flags.conf as an extra argument.
          rm -f $out/bin/google-chrome-stable
          cat > $out/bin/google-chrome-stable <<'WRAPPER'
          #!${pkgs.runtimeShell}
          conf="''${XDG_CONFIG_HOME:-$HOME/.config}/chrome-flags.conf"
          flags=()
          if [[ -r "$conf" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
              [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
              flags+=("$line")
            done < "$conf"
          fi
          exec ${pkgs.google-chrome}/bin/google-chrome-stable "$@" "''${flags[@]}"
          WRAPPER
          chmod +x $out/bin/google-chrome-stable

          # Point the desktop entries at the wrapper (turn symlinks into real, writable copies first).
          if [ -L $out/share/applications ]; then
            real=$(readlink -f $out/share/applications)
            rm $out/share/applications
            mkdir -p $out/share/applications
            cp -r "$real"/. $out/share/applications/
          fi
          for f in $out/share/applications/*.desktop; do
            [ -e "$f" ] || continue
            cp --remove-destination "$(readlink -f "$f")" "$f"
            chmod u+w "$f"
            sed -i \
              -e "s|${pkgs.google-chrome}/bin/google-chrome-stable|$out/bin/google-chrome-stable|g" \
              -e "s|^Exec=google-chrome-stable|Exec=$out/bin/google-chrome-stable|" \
              "$f"
          done
        '';
      };
    in
    {
      home.packages = [
        chrome-wrapped
        chrome-hdr
      ];
    };
}
