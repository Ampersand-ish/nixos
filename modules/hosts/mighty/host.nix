# mighty: ITX desktop — Intel Core Ultra 270K (Arrow Lake) on ROG Strix B860-I Gaming WiFi,
# RX 9070 XT, 2 TB NVMe system disk (LUKS2+btrfs via disko) + 4 TB NVMe data disk.
# Before install: add secrets/mighty.yaml; fill the 4 TB UUID in data-disk.nix once the disk is attached.
{ inputs, config, ... }:
{
  flake.nixosConfigurations.mighty = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules =
      (with config.flake.modules.nixos; [
        host-spec
        nixpkgs-config
        nix
        mighty-hardware
        initrd
        lanzaboote
        hibernate
        disko-luks-btrfs
        mighty-data-disk
        btrfs-maintenance
        zram
        kernel-cachyos
        kernel-tuning
        amdgpu
        tpm
        bluetooth
        audio
        printing
        udev
        firmware
        power
        networkmanager
        nm-profiles
        firewall
        avahi
        ssh
        sddm
        niri
        portals
        keyring-polkit
        gnome-services
        flatpak
        fonts
        gaming
        stylix
        docker
        users
        users-sops-password
        locale
        sops
        home-manager
        base-cli
      ])
      ++ [
        {
          hostSpec = {
            name = "mighty";
            # The Crucial P3 Plus 2 TB — today moonwhite's /mnt/Files disk; disko WIPES it,
            # so every byte on it must be on the 4 TB data disk before the install.
            osDisk = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2522E9C17380";
            espSize = "2G";
            swapSize = "40G"; # 32G RAM + headroom for the hibernation image
            kernelVariant = "latest-x86_64-v3";
            gpu = "amdgpu";
            resumeOffset = 533760; # post-install: btrfs inspect-internal map-swapfile -r /swap/swapfile
          };

          # SSH in from moonwhite (ssh module keeps the port closed by default).
          networking.firewall.allowedTCPPorts = [ 22 ];
          users.users.ampersand.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAgq4WLmBiwg6RosTOBVvvS238p5Ma6PnamZuE6yIIx ampersand@moonwhite"
          ];

          home-manager.users.ampersand = {
            imports = with config.flake.modules.homeManager; [
              base
              shell
              niri
              noctalia
              stylix
              gtk-qt
              portals-mime
              ghostty
              neovim
              mpv
              btop
              mpd
              easyeffects
              git
              opencode
              kdeconnect
              mangohud
              cloud
              udiskie
              chrome
              pkgs-cli
              pkgs-dev
              pkgs-media
              pkgs-gaming
              pkgs-cad
              pkgs-comms
              pkgs-office
            ];
            desktop.niri.outputs = builtins.readFile ../../../home/niri/hosts/mighty/outputs.kdl;
            # Repo checkout on mighty is ~/nixos, not ~/Desktop/nixos — out-of-store symlinks point there.
            desktop.flakeDir = "/home/ampersand/nixos";
          };

          system.stateVersion = "26.05";
        }
      ];
  };
}
