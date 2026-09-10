# Installing moonwhite

Pre-flight (on the old system)
1. Back up to `/mnt/Files/migration/`: `sudo cp -a /var/lib/sbctl`, `~/.dots`, `sudo cp -a /etc/NetworkManager/system-connections`,
   `~/.config`, `~/.local/share`, `~/.ssh`, `~/.gnupg`, `~/.local/share/keyrings`.
2. Generate the host key now: `ssh-keygen -t ed25519 -N "" -f /mnt/Files/migration/ssh_host_ed25519_key`;
   put `ssh-to-age < …pub` into `.sops.yaml`; create `secrets/moonwhite.yaml` + `secrets/nm.env` (see secrets/README.md); commit.
3. Build everything once with a disk-backed store and export it as a local cache:
   `nix build .#nixosConfigurations.moonwhite.config.system.build.toplevel && nix copy --to file:///mnt/Files/migration/nix-cache ./result`
4. Note the LUKS passphrase you will type into disko.

Install (NixOS minimal ISO; Secure Boot **temporarily disabled** in firmware — do NOT clear/reset keys)
5. `nmcli dev wifi connect <ssid> password <psk>`; `sudo -i`
6. `mount -o ro /dev/disk/by-uuid/a425327f-f5e7-45e0-91c0-a26f0fb0aedd /mnt/Files`; `git clone` (or copy) this repo to `/root/nixos`
7. `nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake /root/nixos#moonwhite`
   → only the SN735 (`hostSpec.osDisk`) is touched. Verify with `lsblk` that `nvme0n1` (Crucial, /mnt/Files) is untouched.
8. `mkdir -p /mnt/var/lib/sbctl /mnt/etc/ssh && cp -a /mnt/Files/migration/sbctl/{GUID,keys} /mnt/var/lib/sbctl/`
   (omit files.json/bundles.json); `cp /mnt/Files/migration/ssh_host_ed25519_key* /mnt/etc/ssh/ && chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key`
9. `mkdir -p /mnt/tmp && export TMPDIR=/mnt/tmp`
   `nixos-install --flake /root/nixos#moonwhite --no-root-passwd --accept-flake-config \
      --option extra-substituters "file:///mnt/Files/migration/nix-cache https://attic.xuyh0120.win/lantian https://niri.cachix.org" \
      --option require-sigs false`
10. `nixos-enter --root /mnt -c 'sbctl verify'` → every `.EFI` under /boot/EFI signed. `umount -R /mnt`, reboot, re-enable Secure Boot.

First boot
11. Passphrase → SDDM → niri. `bootctl status` must say `Secure Boot: enabled (user)`.
12. TPM2 enrol: `sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 /dev/disk/by-id/nvme-WD_PC_SN735_SDBPNHH-1T00-1002_21481D803771-part2`
    (re-run with `--wipe-slot=tpm2` after firmware updates). Reboot: no prompt.
13. Hibernation: `sudo btrfs inspect-internal map-swapfile -r /swap/swapfile` → set `hostSpec.resumeOffset` in
    `modules/hosts/moonwhite/host.nix`; `nh os switch`; test `systemctl hibernate`.
14. GNOME keyring is unlocked by PAM at SDDM login (same password as the user account) — nothing to do.
15. `rm ~/.local/state/noctalia/settings.toml` once (stale GUI state); restore `~/.config/rclone/rclone.conf`,
    Dropbox/Chrome profiles, `~/.local/share/{keyrings,remmina}` from the backup.
16. `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo` and reinstall Riff/SciDAVis/Picard.

# Installing mighty (fresh machine)

No migration to carry over — differences from the moonwhite flow above:

1. `hostSpec.osDisk` is already set: the Crucial P3 Plus 2 TB (`nvme-CT2000P3PSSD8_2522E9C17380`) —
   the disk that today holds moonwhite's `/mnt/Files`. **Disko wipes it**: before pulling it from the
   laptop, copy everything on `/mnt/Files` to the 4 TB data disk and verify the copy. The 4 TB already
   contains data and must never be formatted.
2. Host key + secrets *before* install: `ssh-keygen -t ed25519 -N "" -f ssh_host_ed25519_key`, put
   `ssh-to-age < ssh_host_ed25519_key.pub` into `.sops.yaml` as the `mighty` recipient,
   `sops updatekeys secrets/*` (re-encrypts nm.env for the new host), and create `secrets/mighty.yaml`
   with `users/ampersand: <mkpasswd -m yescrypt hash>` — this is the login password; it is baked in via
   sops, not asked on first boot. Commit.
3. Secure Boot: fresh board, so no key reuse. In firmware, clear/erase Secure Boot keys to enter **Setup Mode**
   and leave Secure Boot off for the install. After disko + the host-key copy, from the installer:
   `nixos-enter --root /mnt -c 'sbctl create-keys'`, then install, then after first boot
   `sudo sbctl enroll-keys -m` (keep the `-m` Microsoft option) and re-enable Secure Boot.
4. Disko: `... disko ... --flake /root/nixos#mighty` — only the 2 TB disk (`hostSpec.osDisk`) is touched;
   verify with `lsblk` that the 4 TB is untouched before AND after. The LUKS passphrase you type here is
   what you enter at every boot until TPM2 is enrolled (step 12 above, with the mighty osDisk `-part2`).
5. Data disk (no formatting!): from the live ISO or first boot, `blkid /dev/disk/by-id/<the-4TB-nvme>*`,
   put the partition UUID (and fsType, if not ext4) into `modules/hosts/mighty/data-disk.nix`, rebuild —
   it mounts at `/mnt/Files`.
6. Monitor: `home/niri/hosts/mighty/outputs.kdl` already carries the MPG321URX (4K@240, VRR, HDR) as the
   sole output — adjust only if more monitors get attached.
