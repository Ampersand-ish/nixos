# nixos — dendritic flake

NixOS configuration for `moonwhite` (ASUS ROG Zephyrus G15 GA503RW, RTX 3070 Ti, HDR OLED), the
`mighty` desktop (Core Ultra 270K on ROG Strix B860-I, RX 9070 XT), and a `vm` for validation. Built around **spicy-niri** + **noctalia**, the **CachyOS kernel**,
**disko** (LUKS2 + btrfs), **lanzaboote** (Secure Boot), TPM2 auto-unlock, **home-manager**, **Stylix**, **sops-nix**.

## Layout

Every `.nix` under `modules/` is a flake-parts module (auto-imported by `import-tree`). Aspects contribute
`flake.modules.nixos.<aspect>` and/or `flake.modules.homeManager.<aspect>`; hosts (`modules/hosts/*`) compose them.
Per-host facts live in `hostSpec.*` (`modules/flake/host-spec.nix`). Non-Nix assets are under `home/`,
packages under `pkgs/`.

| Dir | What |
|---|---|
| `modules/boot` | systemd initrd, lanzaboote / systemd-boot, hibernation |
| `modules/storage` | disko layout (parameterised), /mnt/Files, zram, scrub |
| `modules/kernel` | CachyOS kernel + tuning (params, sysctl, ananicy) |
| `modules/graphics` | nvidia (HDR chain) / amdgpu / virtio |
| `modules/hardware` | asus (asusd, supergfxd), tpm, bluetooth, audio, printing, udev, firmware, power |
| `modules/desktop` | sddm, niri, noctalia, stylix, gtk/qt, portals, keyring/polkit, fonts, gaming, flatpak |
| `modules/apps` | home-manager app configs (shell, ghostty, neovim, mpv, …) |
| `modules/home` | HM base (out-of-store symlinks, seeding) + package lists |
| `home/` | verbatim configs: niri KDL, noctalia TOML, nvim, wallpapers, scripts, ICC |

## Daily use

```
nh os switch            # rebuild (flake path is configured in programs.nh)
nh os boot              # build + set as next boot without switching
nh clean all            # runs weekly automatically as well
nix flake update        # bump everything; or: nix flake update niri-spicy-src smithay-spicy-src
```

Mutable, out-of-store directories (edit in place, commit when happy): `home/nvim`, `home/opencode`, `home/rclone`,
`home/easyeffects`, `home/wallpapers`. Files noctalia generates at runtime (`~/.config/niri/noctalia.kdl`,
`gtk-*/noctalia.css`, ghostty/btop themes, `nvim/lua/matugen.lua`, …) are intentionally **not** managed.
Noctalia GUI changes go to `~/.local/state/noctalia/settings.toml`; to make them declarative:
`noctalia config export > home/noctalia/config.toml`, strip the runtime sections, commit, delete `settings.toml`.

## Validation

```
nix flake check
nix build .#niri-spicy && result/bin/niri --version
nixos-rebuild build-vm --flake .#vm && ./result/bin/run-vm-vm      # SDDM -> niri -> noctalia
nix build .#nixosConfigurations.moonwhite.config.system.build.toplevel
```

## Install (moonwhite)

See `docs/INSTALL.md`.
