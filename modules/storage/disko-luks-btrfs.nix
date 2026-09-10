# disko layout: GPT -> ESP + LUKS2(argon2id, 4K sectors, TPM2-ready) -> btrfs subvolumes + swapfile.
# Parameterised by hostSpec.osDisk / espSize / swapSize so every host reuses it.
{ inputs, ... }:
{
  flake.modules.nixos.disko-luks-btrfs =
    { config, lib, ... }:
    let
      spec = config.hostSpec;
      zstd = [
        "compress=zstd:1"
        "noatime"
      ];
    in
    {
      imports = [ inputs.disko.nixosModules.disko ];

      assertions = [
        {
          assertion = spec.osDisk != null;
          message = "hostSpec.osDisk must be set for the disko-luks-btrfs aspect";
        }
      ];

      disko.devices.disk.os = {
        type = "disk";
        device = spec.osDisk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = spec.espSize;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [
                  "-n"
                  "ESP"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                askPassword = true;
                extraFormatArgs = [
                  "--type"
                  "luks2"
                  "--pbkdf"
                  "argon2id"
                  "--sector-size"
                  "4096"
                  "--label"
                  "cryptroot"
                ];
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                  crypttabExtraOpts = [ "tpm2-device=auto" ];
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "nixos"
                  ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = zstd;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = zstd;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = zstd;
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = zstd;
                    };
                    "@cache" = {
                      mountpoint = "/var/cache";
                      mountOptions = zstd;
                    };
                    "@tmp" = {
                      mountpoint = "/var/tmp";
                      mountOptions = zstd;
                    };
                    "@srv" = {
                      mountpoint = "/srv";
                      mountOptions = zstd;
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      mountOptions = [ "noatime" ];
                      swap.swapfile.size = spec.swapSize;
                    };
                  };
                };
              };
            };
          };
        };
      };

      fileSystems."/var/log".neededForBoot = true;
      boot.tmp.useTmpfs = true;
    };
}
