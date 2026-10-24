# Flake overlay with our own packages, plus perSystem exposure for `nix build .#<pkg>`.
{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    niri-spicy = final.callPackage ../../pkgs/niri-spicy/package.nix {
      niriSrc = inputs.niri-spicy-src;
      smithaySrc = inputs.smithay-spicy-src;
    };
    sddm-theme-field = final.callPackage ../../pkgs/sddm-theme-field/package.nix { };

    # opencode from upstream (sst/opencode) for latest releases. Call their
    # packaging files directly and take the node_modules output hash from their
    # committed hashes.json so input bumps need no manual hash updates.
    # Caveat: if nixpkgs' bun drifts from the one upstream used to generate it,
    # the build fails with a hash mismatch -- pin a hash here temporarily.
    opencode =
      let
        hashes = builtins.fromJSON (builtins.readFile (inputs.opencode + "/nix/hashes.json"));
        node-modules = final.callPackage (inputs.opencode + "/nix/node_modules.nix") {
          rev = builtins.substring 0 7 inputs.opencode.rev;
          hash = hashes.nodeModules.${final.stdenv.hostPlatform.system};
        };
      in
      (final.callPackage (inputs.opencode + "/nix/opencode.nix") {
        node_modules = node-modules;
      }).overrideAttrs (old: {
        # build.ts imports ../../../script/native-arch, but upstream's
        # node_modules.nix fileset omits the root script/ dir.
        src = inputs.opencode;
      });

    # rclone's MEGA backend persists session state (session_id/master_key) by
    # rewriting its --config file after each fresh login. With the fstab mount
    # (modules/system/rclone-mega.nix) the config is the read-only sops-installed
    # /run/secrets/rclone.conf: the rewrite fails loudly when the helper runs
    # unprivileged (gvfs/setuid mount) and, worse, succeeds when run by systemd
    # as root -- temp-file+rename flips the secret's owner back to root,
    # re-breaking the user mount path until the next activation. Wrap
    # mount.rclone so rclone always gets a writable per-uid copy and never sees
    # the secret itself as its config.
    rclone =
      let
        helper = final.writeShellScript "mount.rclone-helper" ''
          set -euo pipefail
          cu="${final.coreutils}/bin"
          # exec via the mount.rclone symlink (not bin/rclone): rclone enables
          # its fstab-helper arg parsing when argv[0] basename is mount.rclone.
          rclone="${prev.rclone}/bin/mount.rclone"

          spec="$1"; shift
          mountpoint="$1"; shift

          # find the -o options string
          opts=""
          prevopt=""
          for a in "$@"; do
            if [ "$prevopt" = "-o" ]; then opts="$a"; fi
            prevopt="$a"
          done

          src=""
          case "$opts" in
            *config=*)
              src="''${opts#*config=}"
              src="''${src%%,*}"
              ;;
          esac

          if [ -n "$src" ]; then
            if [ "$("$cu/id" -u)" -eq 0 ]; then
              dest="/var/lib/rclone-mount/rclone.conf"
            else
              dest="''${XDG_CACHE_HOME:-''${HOME:-/tmp}}/rclone/rclone.conf"
            fi
            "$cu/mkdir" -p -- "$("$cu/dirname" -- "$dest")"
            # Reuse an existing copy so persisted backend session state survives
            # between mounts; recopy (dropping stale sessions) when the secret
            # changes. A failed read falls through to rclone's own error.
            sum="$("$cu/sha256sum" -- "$src" 2>/dev/null | "$cu/cut" -d' ' -f1)" || sum=""
            if [ -n "$sum" ]; then
              if [ ! -f "$dest" ] || [ "$("$cu/cat" "$dest.src.sha256" 2>/dev/null)" != "$sum" ]; then
                "$cu/cat" -- "$src" > "$dest"
                "$cu/chmod" 600 "$dest"
                printf '%s\n' "$sum" > "$dest.src.sha256"
              fi
              args=()
              prevopt=""
              for a in "$@"; do
                if [ "$prevopt" = "-o" ]; then a="''${a//$src/$dest}"; fi
                args+=("$a")
                prevopt="$a"
              done
              exec "$rclone" "$spec" "$mountpoint" "''${args[@]}"
            fi
          fi
          exec "$rclone" "$spec" "$mountpoint" "$@"
        '';
      in
      prev.rclone.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm $out/bin/mount.rclone
          ln -s ${helper} $out/bin/mount.rclone
        '';
      });

    # Zotero 10.0.4 in nixpkgs breaks against Firefox ESR 153 (Zotero's omni.ja
    # patch script targets ESR 140) -- see the nixpkgs-zotero input in flake.nix.
    zotero = inputs.nixpkgs-zotero.legacyPackages.${final.system}.zotero;

    # 0.8.2 regressed Steam popup/context menus (open then instantly dismiss).
    # Pin to 0.8.1 until upstream lands a fix. cargoDeps must be rebuilt alongside
    # src (overriding cargoHash alone keeps the old vendor derivation).
    xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
      version = "0.8.1";
      src = final.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xwayland-satellite";
        tag = "v0.8.1";
        hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
      };
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        name = "xwayland-satellite-0.8.1-vendor";
        src = final.fetchFromGitHub {
          owner = "Supreeeme";
          repo = "xwayland-satellite";
          tag = "v0.8.1";
          hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
        };
        hash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
      };
      cargoHash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
    });
  };

  perSystem =
    { pkgs, system, ... }:
    let
      ours = inputs.self.overlays.default pkgs pkgs;
    in
    {
      packages = {
        inherit (ours) niri-spicy sddm-theme-field;
      };
    };
}
