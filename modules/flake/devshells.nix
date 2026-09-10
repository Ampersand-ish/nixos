# Development shells: `nix develop` (nix tooling), `nix develop .#python`, `.#rust`, `.#qt6`.
# Qt shells use the nixpkgs-manual pattern (wrapQtAppsHook + re-exec'd bash) so QT_PLUGIN_PATH/QML paths are set.
{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      qtLibs = with pkgs.qt6; [
        qtbase
        qtdeclarative
        qtwayland
        qtsvg
        qttools
        qtmultimedia
        qt5compat
      ];
      qtShellHook = ''
        bashdir=$(mktemp -d)
        makeWrapper "$(type -p bash)" "$bashdir/bash" "''${qtWrapperArgs[@]}"
        exec "$bashdir/bash"
      '';
      pythonEnv = pkgs.python3.withPackages (
        ps: with ps; [
          pip
          ipython
          numpy
          scipy
          matplotlib
          pandas
          requests
          pyqt6
          pyside6
          pytest
          black
          ruff
        ]
      );
    in
    {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nil
            nix-output-monitor
            nvd
            sops
            age
            ssh-to-age
            deadnix
            statix
          ];
        };

        python = pkgs.mkShell {
          packages =
            with pkgs;
            [
              pythonEnv
              uv
              pyright
            ]
            ++ qtLibs;
          nativeBuildInputs = with pkgs; [
            qt6.wrapQtAppsHook
            makeWrapper
          ];
          shellHook = qtShellHook;
        };

        rust = pkgs.mkShell {
          packages =
            with pkgs;
            [
              rustc
              cargo
              clippy
              rustfmt
              rust-analyzer
              cargo-watch
              cargo-edit
              pkg-config
              openssl
              cmake
            ]
            ++ qtLibs; # cxx-qt / qmetaobject users get Qt6 via pkg-config
          nativeBuildInputs = with pkgs; [
            qt6.wrapQtAppsHook
            makeWrapper
          ];
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          shellHook = qtShellHook;
        };

        qt6 = pkgs.mkShell {
          packages =
            with pkgs;
            [
              cmake
              ninja
              gcc
              gdb
              pkg-config
              qtcreator
              kdePackages.qtdoc
            ]
            ++ qtLibs;
          nativeBuildInputs = with pkgs; [
            qt6.wrapQtAppsHook
            makeWrapper
          ];
          shellHook = qtShellHook;
        };
      };
    };
}
