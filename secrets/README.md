# Secrets (sops-nix)

Encrypted with age. Recipients are listed in `../.sops.yaml`:
- your admin key (`age-keygen -o ~/.config/sops/age/keys.txt`, or `ssh-to-age -private-key -i ~/.ssh/id_ed25519`)
- each host's ssh host key (`ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`)

Files:
- `moonwhite.yaml` — `users/ampersand: <mkpasswd -m yescrypt hash>`
- `mighty.yaml` — same shape, for the desktop
- `nm.env` — dotenv for NetworkManager `ensureProfiles`:
  ```
  HOME_SSID=...
  HOME_PSK=...
  ```

Workflow:
```
nix shell nixpkgs#sops nixpkgs#age nixpkgs#ssh-to-age
sops secrets/moonwhite.yaml        # edit/create (encrypted on save)
sops --input-type dotenv --output-type dotenv secrets/nm.env
```
For a fresh host, generate its ssh host key *before* install (`ssh-keygen -t ed25519 -N "" -f ssh_host_ed25519_key`),
add its age recipient to `.sops.yaml`, `sops updatekeys secrets/*.yaml`, and copy the key to `/mnt/etc/ssh/` after disko.
