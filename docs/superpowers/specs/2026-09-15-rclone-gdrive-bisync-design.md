# rclone Google Drive bisync (sops-declarative, scheduled)

Date: 2026-09-15
Status: approved design (spec)

## Goal

Manage a Google Drive remote for `rclone` declaratively through sops, and run a
scheduled two-way sync (`rclone bisync`) between `/mnt/Files/PhD` and
`gdrive:PhD` on both hosts (`mighty`, `moonwhite`) as a home-manager **user**
service.

## Non-goals

- No system-level service (approach 3 was chosen deliberately).
- No `.git` exclusion.
- No client-side encryption on Drive.
- No `rclone mount` filesystem.

## Decisions

- **Approach 3** — home-manager user service + timer. Chosen over a system
  service and over the "regenerate a writable config from a token-only secret"
  variant.
- **Secret content** — the complete rclone config file (INI, including the OAuth
  `token` JSON), one per host, stored in `secrets/<host>.yaml`.
- **Sync direction** — two-way `rclone bisync`.
- **Schedule** — every 30 minutes, staggered per host, with catch-up.
- **Linger** — enabled so the timer runs without an active login session.

## Components

| File | Change |
|---|---|
| `modules/apps/cloud.nix` | Add NixOS aspect `flake.modules.nixos.cloud` (sops secret, linger). Extend HM aspect `cloud` (option, user service/timer, wrapper package, session env). Drop `desktop.outOfStore.rclone`. |
| `home/scripts/rclone-bisync` | New wrapper: normal bisync, `--resync` only on first run. |
| `modules/hosts/mighty/host.nix` | Add `cloud` to the NixOS import list. |
| `modules/hosts/moonwhite/host.nix` | Add `cloud` to the NixOS import list. |
| `secrets/mighty.yaml`, `secrets/moonwhite.yaml` | New `rclone.conf` key (user action). |

HM aspect `cloud` is already imported by both hosts; only the NixOS aspect needs
adding to host import lists.

## Secret

Declared in the NixOS aspect:

```nix
sops.secrets."rclone.conf" = {
  owner = "ampersand";
  mode = "0400";
};
```

Default path is `/run/secrets/rclone.conf`. It is readable by the user's session
and the user service. Content:

```ini
[gdrive]
type = drive
scope = drive
token = {"access_token":"...","token_type":"Bearer","refresh_token":"...","expiry":"..."}
```

The token is obtained once per host with an interactive `rclone config`
(built-in drive client, `scope=drive`).

## Home-manager option

```nix
options.desktop.rcloneSync = {
  enable = lib.mkEnableOption "scheduled rclone bisync of the PhD folder to Google Drive";
  localPath = lib.mkOption {
    type = lib.types.str;
    default = "/mnt/Files/PhD";
  };
  remotePath = lib.mkOption {
    type = lib.types.str;
    default = "gdrive:PhD";
  };
  extraExcludes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
};
```

## Service and timer

```nix
systemd.user.services.rclone-bisync = {
  Unit.Description = "rclone bisync /mnt/Files/PhD <-> gdrive:PhD";
  Service = {
    Type = "oneshot";
    ExecStart = "${rclone-bisync}/bin/rclone-bisync";
    Environment = [ "RCLONE_CONFIG=/run/secrets/rclone.conf" ];
  };
};

systemd.user.timers.rclone-bisync = {
  Timer = {
    OnCalendar = "*-*-* *:5/30:00";   # mighty  (:05, :35)
    Persistent = true;
    RandomizedDelaySec = "3m";
  };
  Install.WantedBy = [ "timers.target" ];
};
```

`moonwhite` uses `*:20/30` (`:20`, `:50`) to reduce overlap on the shared
remote.

## Wrapper `home/scripts/rclone-bisync`

- `--resync` only when no prior bisync listing exists under
  `$HOME/.cache/rclone/bisync` (glob `*.lst`); otherwise a plain resume.
- Common flags: `--resilient --recover --max-lock 2m --conflict-resolve newer`.
- Excludes: `.venv/**`, `__pycache__/**`, `.pytest_cache/**`,
  `node_modules/**`, `*.pyc`, `*.tmp`, plus `extraExcludes`.
- Logs to the user journal (no `--log-file`), so
  `journalctl --user -u rclone-bisync` works.

Bisync state lives under `$HOME/.cache/rclone/bisync` (writable) — the read-only
sops config only affects OAuth token refresh, which reuses the long-lived refresh
token and may emit a benign "Failed to save config" line.

## Manual use and migration

- Remove `desktop.outOfStore.rclone = "home/rclone"`.
- Set `RCLONE_CONFIG=/run/secrets/rclone.conf` in the shell session so plain
  `rclone lsd gdrive:` works.
- `~/nixos/home/rclone/rclone.conf` (gitignored stub) becomes unused; delete it.
- If `~/.config/rclone` remains as an orphan symlink to `home/rclone` after the
  rebuild, remove it once (`rm ~/.config/rclone`).

## User actions (outside the diff)

1. Obtain the OAuth token per host:
   `rclone config` → new remote `gdrive`, type `drive`, scope `drive`.
2. `nix shell nixpkgs#sops nixpkgs#age nixpkgs#ssh-to-age`, then
   `sops secrets/<host>.yaml` and add the `rclone.conf` key.

## Validation

- `nix flake check`
- `nix build .#nixosConfigurations.mighty.config.system.build.toplevel`
- `nix build .#nixosConfigurations.moonwhite.config.system.build.toplevel`
- Runtime: `systemctl --user start rclone-bisync`, then
  `journalctl --user -u rclone-bisync` and `rclone lsd gdrive:`.

## Open items

- `moonwhite`'s `/mnt/Files/PhD` must exist before its first `--resync`, or
  `--resync` will pull the remote tree down.
- Two hosts bisyncing the same remote can still conflict if the same file is
  edited on both between runs; staggering and `--max-lock` mitigate but do not
  eliminate this.
