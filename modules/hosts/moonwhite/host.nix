# moonwhite: ASUS ROG Zephyrus G15 GA503RW, RTX 3070 Ti (MUX dGPU), LUKS2+TPM2, lanzaboote.
{ inputs, config, ... }:
{
  flake.nixosConfigurations.moonwhite = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules =
      (with config.flake.modules.nixos; [
        host-spec
        nixpkgs-config
        nix
        moonwhite-hardware
        initrd
        lanzaboote
        hibernate
        disko-luks-btrfs
        files-disk
        btrfs-maintenance
        zram
        kernel-cachyos
        kernel-tuning
        nvidia
        asus
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
        ollama
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
            name = "moonwhite";
            osDisk = "/dev/disk/by-id/nvme-WD_PC_SN735_SDBPNHH-1T00-1002_21481D803771";
            espSize = "2G";
            swapSize = "20G";
            kernelVariant = "latest-x86_64-v3";
            gpu = "nvidia";
            resumeOffset = null; # post-install: btrfs inspect-internal map-swapfile -r /swap/swapfile
          };

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
              icc
              pkgs-cli
              pkgs-dev
              pkgs-media
              pkgs-gaming
              pkgs-cad
              pkgs-comms
              pkgs-office
            ];
            desktop.niri.outputs = builtins.readFile ../../../home/niri/hosts/moonwhite/outputs.kdl;
            desktop.icc.enable = true;
          };

          system.stateVersion = "26.05";
        }
      ];
  };
}
