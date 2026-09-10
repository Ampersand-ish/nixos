# spicy-niri: losnoco/niri (spicy-main) built against losnoco/smithay (spicy-master).
# The fork references smithay as a sibling *path* dependency (../smithay), so both sources are
# joined into one tree. Vulkan renderer needs shaderc; SHADERC_LIB_DIR makes shaderc-sys link
# the Nix library instead of trying to build shaderc with cmake/git inside the sandbox.
{
  lib,
  rustPlatform,
  runCommand,
  installShellFiles,
  pkg-config,
  wayland,
  libgbm,
  libglvnd,
  seatd,
  libinput,
  libdisplay-info_0_3,
  libxkbcommon,
  pango,
  cairo,
  pixman,
  glib,
  dbus,
  pipewire,
  systemd,
  shaderc,
  vulkan-loader,
  autoAddDriverRunpath,
  niriSrc,
  smithaySrc,
}:
let
  date = builtins.substring 0 8 (niriSrc.lastModifiedDate or "19700101");
  fmtDate = "${builtins.substring 0 4 date}-${builtins.substring 4 2 date}-${builtins.substring 6 2 date}";
  shortRev = niriSrc.shortRev or "dirty";
  combined = runCommand "niri-spicy-source" { } ''
    mkdir -p $out
    cp -r ${niriSrc} $out/niri
    cp -r ${smithaySrc} $out/smithay
    chmod -R u+w $out
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "niri-spicy";
  version = "26.04-unstable-${fmtDate}";

  src = combined;
  sourceRoot = "${combined.name}/niri";

  # Lockfile records smithay/smithay-drm-extras as path packages; no git deps => no outputHashes.
  cargoLock.lockFile = "${niriSrc}/Cargo.lock";

  postPatch = ''
    # Make smithay a plain path dependency so cargo never consults the git source in the manifest.
    sed -i -e '/^\[patch\."https:\/\/github\.com\/Smithay\/smithay\.git"\]/,/^$/d' Cargo.toml
    sed -i \
      -e '/^\[workspace\.dependencies\.smithay\]/,/^$/{s|^git = .*|path = "../smithay"|;/^rev = /d;/^branch = /d}' \
      -e '/^\[workspace\.dependencies\.smithay-drm-extras\]/,/^$/{s|^git = .*|path = "../smithay/smithay-drm-extras"|;/^rev = /d;/^branch = /d}' \
      Cargo.toml
    # Inline-table form: smithay = { git = "...", rev = "..." }
    sed -i -E \
      -e 's|^smithay = \{ *git = "[^"]*"(, *(rev\|branch) = "[^"]*")? *(, *)?|smithay = { path = "../smithay"\3|' \
      -e 's|^smithay-drm-extras = \{ *git = "[^"]*"(, *(rev\|branch) = "[^"]*")? *(, *)?|smithay-drm-extras = { path = "../smithay/smithay-drm-extras"\3|' \
      Cargo.toml
    grep -q 'path = "../smithay"' Cargo.toml || { echo "smithay path patch failed"; grep -n smithay Cargo.toml; exit 1; }

    patchShebangs resources/niri-session
    substituteInPlace resources/niri.service --replace-fail 'niri' "$out/bin/niri"
  '';

  strictDeps = true;
  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    installShellFiles
    autoAddDriverRunpath
  ];
  buildInputs = [
    wayland
    libgbm
    libglvnd
    seatd
    libinput
    libdisplay-info_0_3
    libxkbcommon
    pango
    cairo
    pixman
    glib
    dbus
    pipewire
    systemd
    shaderc
    vulkan-loader
  ];

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "dbus"
    "systemd"
    "xdp-gnome-screencast"
  ];
  cargoBuildFlags = [
    "--package"
    "niri"
  ];

  env = {
    SHADERC_LIB_DIR = "${lib.getLib shaderc}/lib";
    NIRI_BUILD_VERSION_STRING = "${finalAttrs.version} (spicy ${shortRev})";
    RUSTFLAGS = toString (
      map (a: "-C link-arg=" + a) [
        "-Wl,--push-state,--no-as-needed"
        "-lEGL"
        "-lwayland-client"
        "-Wl,--pop-state"
      ]
    );
  };

  doCheck = false;

  outputs = [
    "out"
    "doc"
  ];
  postInstall = ''
    install -Dm0644 README.md resources/default-config.kdl -t $doc/share/doc/niri
    if [ -d docs/wiki ]; then cp -r docs/wiki $doc/share/doc/niri/wiki; fi
    install -Dm0644 resources/niri.desktop -t $out/share/wayland-sessions
    install -Dm0644 resources/niri-portals.conf -t $out/share/xdg-desktop-portal
    install -Dm0755 resources/niri-session -t $out/bin
    install -Dm0644 resources/niri-shutdown.target resources/niri.service -t $out/lib/systemd/user
    installShellCompletion --cmd niri \
      --bash <($out/bin/niri completions bash) \
      --fish <($out/bin/niri completions fish) \
      --zsh <($out/bin/niri completions zsh)
  '';
  postFixup = ''
    # ash dlopen()s libvulkan.so.1 at runtime; keep it findable.
    patchelf --add-rpath ${lib.makeLibraryPath [ vulkan-loader ]} $out/bin/niri
  '';

  passthru = {
    providedSessions = [ "niri" ];
    inherit niriSrc smithaySrc;
  };

  meta = {
    description = "Scrollable-tiling Wayland compositor, with losnoco's spicy patches (Vulkan renderer, HDR, blur)";
    homepage = "https://github.com/losnoco/niri/tree/spicy-main";
    license = lib.licenses.gpl3Only;
    mainProgram = "niri";
    platforms = lib.platforms.linux;
  };
})
