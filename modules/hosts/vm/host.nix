# vm: validates the flake wiring + niri/DMS/SDDM/home-manager in QEMU (no LUKS, no Secure Boot, no NVIDIA).
#   nixos-rebuild build-vm --flake .#vm && ./result/bin/run-vm-vm
{ inputs, config, ... }:
{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules =
      (with config.flake.modules.nixos; [
        host-spec
        nixpkgs-config
        nix
        systemd-boot
        kernel-cachyos
        kernel-tuning
        virtio
        audio
        networkmanager
        firewall
        avahi
        sddm
        niri
        portals
        keyring-polkit
        gnome-services
        fonts
        stylix
        users
        locale
        home-manager
        base-cli
      ])
      ++ [
        (
          { lib, pkgs, ... }:
          {
            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hostSpec = {
              name = "vm";
              gpu = "virtio";
              kernelVariant = "latest";
            };

            # virgl only offers OpenGL 4.2 and ghostty needs 4.3 -> a fallback terminal for the VM.
            environment.systemPackages = [
              pkgs.foot
              pkgs.firefox
            ];

            # No sops in the VM: static password. sshd + port-forward for debugging from the host.
            users.users.ampersand.initialPassword = "vm";
            users.users.ampersand.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAgq4WLmBiwg6RosTOBVvvS238p5Ma6PnamZuE6yIIx "
            ];
            services.openssh = {
              enable = true;
              settings.PasswordAuthentication = true;
            };
            virtualisation.vmVariant.virtualisation.forwardPorts = [
              {
                from = "host";
                host.port = 2222;
                guest.port = 22;
              }
            ];

            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
            virtualisation.vmVariant.virtualisation = {
              # Share this repo so out-of-store symlinks (wallpapers, nvim, opencode, ...) resolve inside the VM.
              sharedDirectories.repo = {
                source = "/home/ampersand/Desktop/nixos";
                target = "/home/ampersand/Desktop/nixos";
              };
              memorySize = 8192;
              cores = 6;
              diskSize = 40 * 1024;
              qemu.options = [
                "-device virtio-vga"
                "-display gtk,gl=off,show-cursor=on"
              ];
            };

            home-manager.users.ampersand = {
              imports = with config.flake.modules.homeManager; [
                base
                shell
                niri
                dms
                stylix
                gtk-qt
                portals-mime
                ghostty
                neovim
                btop
                git
                udiskie
              ];
              desktop.niri.outputs = "";
            };

            system.stateVersion = "26.05";
          }
        )
      ];
  };
}
